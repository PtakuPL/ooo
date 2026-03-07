# Plan zabezpieczenia klienta i serwera — ticket-gate + tryby gry + blokada dodawania serwerów
**Data**: 2026-03-01  
**Status**: ⏳ W TRAKCIE — architektura i backlog sa opisane, ale runtime/E2E przed kompilacja nie sa jeszcze domkniete (`launcher + WWW + instalka + dual-server`)  
**Źródło**: zarys_planu_modyfikacji_klienta.md + analiza kodu OTClient + Canary  
**Ostatnia aktualizacja postępów**: 2026-03-06 01:31 (uzupelniono mape dokumentacji i referencje do planow 07/08/09/10)

### Legenda ikon statusu
| Ikona | Znaczenie |
|---|---|
| ✅ | Zrobione i zweryfikowane |
| 🟢 | Gotowe, czeka na test/build |
| 🟠 | Wymaga poprawek (znany problem) |
| 🔴 | Bloker — nie skompiluje się / nie zadziała |
| ⬜ | Nie rozpoczęte |
| ⏳ | W trakcie |  

---

## 0.1 Aktualna mapa dokumentacji (source of truth)

Ten dokument jest **glownym opisem architektury i backlogu strategicznego**, ale **nie** jest juz jedynym operacyjnym zrodlem prawdy na jutro.

### Dokumenty aktywne (utrzymywac na biezaco)

1. `00_START_PRACY_CHECKLISTA.md`
- glowna checklista statusow `K*`
- jedyne miejsce, gdzie ma byc widac zbiorczy stan TODO / DONE / PARTIAL

2. `01_DZIENNIK_PRAC.md`
- chronologiczny log zmian, decyzji i wynikow PASS/FAIL/BLOCKED

3. `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md`
- operacyjny plan dnia kompilacji
- gate globalne i harmonogram dnia

4. `08_PLAN_INSTALKA_JUTRO_DETALE.md`
- operacyjny plan instalki i paczki gracza
- gate `G-INS` / `PG-INS`

5. `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md`
- operacyjny plan integracji launcher/API/WWW/RedDAXE/Canary
- gate `G-INT`

6. `10_AUDYT_DOKUMENTACJI_I_BRAKOW_2026-03-06.md`
- audyt brakow dokumentacyjnych, rozjazdow i realnych blockerow przed kompilacja

### Dokumenty aktywne tematyczne (uzupelniaj tylko w swoim zakresie)

1. `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`
- model konta globalnego, dual-server i roadmapa multi-game

2. `04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md`
- portal `/portal` i `/reddaxe`, konto globalne i routing front-door

3. `05_PLAN_SKLEP_SMS_2_BAZY.md`
- sklep/platnosci w modelu 2 baz

4. `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md`
- legacy WWW, i18n, clipping, runtime drift i route issues

### Dokumenty historyczne / referencyjne

1. `2026-03-05_PLAN_PRZED_KOMPILACJA.md`
- archiwalny snapshot, zastapiony przez `07`

2. sprinty launcherowe (`2026-03-03_launcher_sprint*.md`)
- material referencyjny do implementacji launchera, nie glowna checklista na jutro

3. `launcher+rust.md`, `launcher+rust2.md`, `launcher+rust2_zadania.md`
- szczegolowa specyfikacja launchera, helper do implementacji i walidacji kontraktow

### Zasada source of truth

1. Status zadania = `00_START_PRACY_CHECKLISTA.md`.
2. Przebieg pracy i decyzje = `01_DZIENNIK_PRAC.md`.
3. Plan jutra = `07` + `08` + `09`.
4. Ten dokument = szeroka architektura, backlog i uzasadnienia techniczne.

---

## 0. Cel

1. **Gracz NIE MOŻE ręcznie dodawać/edytować serwerów** — lista serwerów jest **widoczna** (gracz widzi dostępne serwery), ale zablokowana jest możliwość dodawania, usuwania i edytowania wpisów przez gracza. Nowe serwery są dodawane **wyłącznie przez launcher** — gdy właściciel uruchomi nowy serwer, launcher przy aktualizacji klienta automatycznie doda go do listy. Gracz nie musi nic robić ręcznie.
2. **Logowanie tylko przez ticket-gate (HMAC)** — serwer gry akceptuje WYŁĄCZNIE kryptograficznie podpisane tickety. Bez poprawnego HMAC = disconnect. To jest TWARDA bariera bezpieczeństwa.
3. **Launcher z auto-update** — gracz uruchamia launcher, który sprawdza pliki i wydaje launch-token. Launcher zarządza również **listą serwerów** — aktualizuje ją automatycznie z serwera API. Launch-token to **dodatkowa warstwa UX/speed-bump**, ale NIE jest kryptograficznym dowodem oficjalnego launchera (patrz sekcja 16.3). Prawdziwą barierą jest ticket-gate.
4. **Tryb Classic 7.4** — po wybraniu gracz widzi TYLKO serwer imitacji 7.4 i nie łączy się z innymi
5. **Tryb Modern** — gracz widzi TYLKO serwer Modern i nie łączy się z serwerem 7.4
6. **Feature flags Classic 7.4** — blokada hotkey na runy, wyłączenie quick-loot, action bar itd.

> **Jak działa aktualizacja listy serwerów:**
> 1. Właściciel dodaje nowy serwer w panelu administracyjnym (API/baza danych)
> 2. Launcher przy starcie pobiera aktualną listę serwerów z API (`GET /api/servers.php` lub z manifestu update)
> 3. Launcher zapisuje zaktualizowaną listę do plików konfiguracyjnych klienta (`init.lua` / `ServerList`)
> 4. Klient startuje z aktualną listą — gracz widzi nowy serwer bez żadnej ręcznej konfiguracji
> 5. Gracz **nie może** dodać własnego serwera — przyciski Add/Remove są zablokowane (`CLIENT_LOCKED = true`)

> **Model bezpieczeństwa — ścisła hierarchia warstw:**
> - **Warstwa TWARDA (nie do obejścia bez klucza serwera)**: Ticket-gate — HMAC-SHA256 podpisany serwerowym kluczem. Sfałszowanie ticketu wymaga złamania klucza HMAC.
> - **Warstwa ŚREDNIA (utrudnia obejście)**: Blokada ServerList w kliencie, wymuszenie trybów, launch-token z IP-binding + jednorazowością.
> - **Warstwa UX/speed-bump (ogranicza przypadkowe/proste obejścia)**: Launcher, filesHash, challenge-response — PyInstaller da się zdekompilować, ale większość graczy tego nie zrobi.

---

## 1. Architektura — 4 warstwy zabezpieczeń

```
┌─────────────────────┐
│  LAUNCHER (.exe)    │  Warstwa 0: Aktualizacja + integralność plików
│  - sprawdza hashe   │
│  - pobiera update   │
│  - uruchamia klient │
└────────┬────────────┘
         │ launch-token (env: OTC_LAUNCH_TOKEN)
         ▼
┌─────────────────────┐
│  KLIENT (instalka)  │  Warstwa 1: UX — ukrywa opcje, wymusza tryb
│  - init.lua config  │
│  - entergame.lua    │
│  - serverlist.lua   │
└────────┬────────────┘
         │ HTTPS (login + ticket request)
         ▼
┌─────────────────────┐
│  API HTTP (MyAcc)   │  Warstwa 2: Brama sesji — wydaje ticket
│  - login.php        │
│  - ticket.php       │
│  - update.php       │
│  - launcher-token   │
└────────┬────────────┘
         │ ticket (podpisany HMAC-SHA256)
         ▼
┌─────────────────────┐
│  SERWER CANARY      │  Warstwa 3: Weryfikacja — nie wpuszcza bez ticketu
│  - protocolgame.cpp │
│  - protocollogin.cpp│
└─────────────────────┘
```

---

## 2. KROK 1 — Klient: Blokada dodawania serwerów + tryby gry ✅

> **UWAGA**: Lista serwerów jest **widoczna** dla gracza — widzi dostępne serwery i może je wybrać.
> Zablokowane jest **tylko** ręczne dodawanie/usuwanie/edytowanie wpisów.
> Nowe serwery dodaje **launcher** automatycznie — właściciel tworzy serwer, launcher aktualizuje klienta, gracz widzi nowy serwer.

### 2.1 Konfiguracja trybów w `init.lua`

Aktualnie `Servers_init` jest zakomentowane. Trzeba je odkomentować i rozbudować:

```lua
-- ==================================================
-- KONFIGURACJA SERWERÓW — TYLKO WŁAŚCICIEL EDYTUJE
-- ==================================================
CLIENT_LOCKED = true  -- blokada dodawania serwerów przez gracza

GameModes = {
    modern = {
        name = "Modern (14.12+)",
        servers = {
            ["https://twoja-domena.pl/login.php"] = {
                port = 443,
                protocol = 1420,
                httpLogin = true,
                worldFilter = "modern"  -- serwer przyjmuje tylko ten tryb
            }
        },
        features = {
            hotkeys_items = true,
            hotkeys_runes = true,
            action_bar = true,
            quick_loot = true,
            smart_equip = true,
            auto_loot = true,
            -- ... pełna lista feature flags
        }
    },
    classic74 = {
        name = "Classic 7.4 (imitacja)",
        servers = {
            ["https://twoja-domena.pl/login.php"] = {
                port = 443,
                protocol = 1420,
                httpLogin = true,
                worldFilter = "classic74"
            }
        },
        features = {
            hotkeys_items = false,    -- ZABLOKOWANE
            hotkeys_runes = false,    -- ZABLOKOWANE
            action_bar = false,       -- UKRYTE
            quick_loot = false,       -- WYŁĄCZONE
            smart_equip = false,      -- WYŁĄCZONE
            auto_loot = false,        -- WYŁĄCZONE
            -- ... itd.
        }
    }
}
```

### 2.2 Pliki do modyfikacji w kliencie

#### A. `init.lua` — dodanie `CLIENT_LOCKED`, `GameModes`, `CurrentGameMode`
- Nowa globalna: `CLIENT_LOCKED = true`
- Nowa globalna: `GameModes = { ... }` — definicja trybów z listą serwerów i feature flags
- Nowa globalna: `CurrentGameMode = nil` — ustawiany po wyborze trybu

#### B. `modules/client_entergame/entergame.lua` — ukrycie UI serwera
Aktualnie `setUniqueServer()` już ukrywa:
- `serverHostTextEdit` → `visible: false, height: 0`
- `serverPortTextEdit` → `visible: false, height: 0`
- `clientBox` → `visible: false, height: 0`
- `serverListButton` → `visible: false, height: 0, width: 0`
- `httpLoginBox` → `visible: false, height: 0`

**Co dodać:**
- Nowy ekran wyboru trybu (przed loginem): "Wybierz tryb gry: [Modern] [Classic 7.4]"
- Po wyborze trybu → `CurrentGameMode = GameModes.modern` lub `GameModes.classic74`
- Automatyczne ustawienie serwera z `CurrentGameMode.servers`
- `EnterGame.init()` sprawdza `CLIENT_LOCKED` i jeśli `true`:
  - Ukrywa pola ręcznego wpisywania hosta/portu/protokołu
  - **Lista serwerów POZOSTAJE WIDOCZNA** — gracz widzi i wybiera serwery
  - Blokuje `ServerList.add()`, `ServerList.remove()` — gracz nie doda/usunie serwera
  - Nie pozwala zmienić `G.host` ręcznie
  - Nowe serwery trafiają na listę **wyłącznie przez launcher** (auto-update z API)

#### C. `modules/client_serverlist/serverlist.lua` — zablokowanie dodawania/usuwania

> Lista serwerów jest **widoczna i przeglądalna**, ale gracz nie może jej modyfikować.
> Launcher aktualizuje listę przy starcie — gdy właściciel doda nowy serwer, pojawi się automatycznie.

```lua
function ServerList.add(host, port, protocol, httpLogin, load)
    if CLIENT_LOCKED and not load then
        return false, 'Server list is locked — serwery aktualizuje launcher'
    end
    -- ... reszta jak jest (load=true pozwala launcherowi/systemowi dodawać)
end

function ServerList.remove(widget)
    if CLIENT_LOCKED then
        return  -- nie pozwalaj usuwać ręcznie
    end
    -- ... reszta jak jest
end
```

#### D. `modules/client_entergame/entergame.otui` — nowy ekran wyboru trybu
Nowy widget `gameModePanel` wyświetlany PRZED panelem loginu:

```otui
UIWidget
  id: gameModePanel
  anchors.fill: parent
  visible: true

  Label
    text: Wybierz tryb gry
    font: verdana-11px-antialised
    text-align: center
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 40

  Button
    id: btnModern
    text: Modern (14.12+)
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: prev.bottom
    margin-top: 20
    size: 200 30

  Button
    id: btnClassic74
    text: Classic 7.4
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: prev.bottom
    margin-top: 10
    size: 200 30
```

### 2.3 Schemat UI

```
[Start klienta]
      │
      ▼
┌─────────────────────┐
│  Wybierz tryb gry:  │  ← gameModePanel (nowy)
│                      │
│  [Modern 14.12+]     │  → CurrentGameMode = "modern"
│  [Classic 7.4]       │  → CurrentGameMode = "classic74"
│                      │
└────────┬─────────────┘
         │
         ▼
┌─────────────────────┐
│  Login              │  ← standardowy entergame, ale:
│  Email: [........]  │    - brak pól serwera (ukryte)
│  Hasło: [........]  │    - brak listy serwerów
│                     │    - brak clientBox
│  [Zaloguj]          │    - serwer ustawiony z GameModes
└─────────────────────┘
```

---

## 3. KROK 2 — API HTTP: Ticket-gate (token sesyjny) ✅

> **UWAGA**: Ten krok opisuje **2-fazowy model** ticket-gate.  
> Ticket NIE jest wydawany razem z login response — jest wydawany OSOBNO, po wyborze postaci.  
> Patrz sekcja 14 dla pełnego, poprawionego diagramu przepływu.

### 3.1 Co to jest ticket-gate

Po poprawnym loginie (email+hasło) API HTTP wydaje **sesję + listę postaci** (BEZ ticketu).  
Gracz wybiera postać, a dopiero wtedy klient żąda **ticketu** z osobnego endpointu (`ticket.php`).  
Ticket (token jednorazowy, krótko żyjący) zawiera `characterName` + `worldId` i jest przedstawiany przy łączeniu z serwerem gry.

### 3.2 Format ticketu (HMAC-SHA256)

```json
{
    "kid": "key-2026-03-a",
    "accountId": 12345,
    "characterName": "PlayerOne",
    "worldId": "classic74",
    "gameMode": "classic74",
    "clientHash": "a1b2c3d4...",
    "clientIp": "83.12.0.0/24",
    "nonce": "random-uuid",
    "issuedAt": 1709312400,
    "expiresAt": 1709312520,
    "signature": "HMAC-SHA256(...)"
}
```

**Pola:**
- `kid` — identyfikator klucza HMAC (key-id), pozwala na rotację kluczy bez downtime
- `accountId` — ID konta
- `characterName` — nazwa wybranej postaci
- `worldId` — identyfikator świata (np. `"classic74"` lub `"modern"`)
- `gameMode` — tryb gry wybrany w kliencie
- `clientHash` — hash binarki klienta (**telemetria/heurystyka**, NIE warunek bezpieczeństwa — da się podrobić w zmodyfikowanym kliencie)
- `clientIp` — maska /24 IP klienta (opcjonalna heurystyka, soft-check z tolerancją na VPN/mobile)
- `nonce` — losowy identyfikator jednorazowy (zapobiega replay attacks)
- `issuedAt` — timestamp wydania
- `expiresAt` — timestamp wygaśnięcia (+30 sekund, z tolerancją ±10s na drift zegarów)
- `signature` — podpis HMAC-SHA256 z kluczem identyfikowanym przez `kid`

### 3.3 Przepływ logowania z ticket-gate (2-FAZOWY)

> **To jest uproszczony diagram.** Pełny, poprawiony flow → sekcja 14.

```
KLIENT                         API HTTP                        SERWER CANARY
  │                               │                               │
  │ FAZA 1 — LOGIN                │                               │
  │ 1. POST /login.php (HTTPS!)   │                               │
  │    {email, password,          │                               │
  │     gameMode, launchToken}    │                               │
  │ ─────────────────────────────>│                               │
  │                               │ 2. Weryfikuj launchToken      │
  │                               │ 3. Weryfikuj email+hasło      │
  │                               │ 4. Filtruj worldy wg gameMode │
  │ 5. Odpowiedź:                 │                               │
  │    {session, characters,      │                               │
  │     worlds}  (BEZ TICKETU!)   │                               │
  │ <─────────────────────────────│                               │
  │                               │                               │
  │ 6. Gracz wybiera postać       │                               │
  │                               │                               │
  │ FAZA 2 — TICKET               │                               │
  │ 7. POST /ticket.php (HTTPS!)  │                               │
  │    {sessionKey, characterName,│                               │
  │     worldId}                  │                               │
  │ ─────────────────────────────>│                               │
  │                               │ 8. Weryfikuj session          │
  │                               │ 9. Sprawdź: postać należy     │
  │                               │    do konta z tej sesji?      │
  │                               │ 10. Sprawdź: worldId dozwolony│
  │                               │     dla gameMode z sesji?     │
  │                               │ 11. Generuj ticket HMAC+nonce │
  │ 12. Odpowiedź:                │                               │
  │    {ticket: "base64.sig"}     │                               │
  │ <─────────────────────────────│                               │
  │                               │                               │
  │ FAZA 3 — CONNECT              │                               │
  │ 13. g_game.loginWorld(        │                               │
  │      ..., sessionKey=ticket)  │                               │
  │ ──────────────────────────────┼──────────────────────────────>│
  │                               │                               │
  │                               │ 14. Weryfikuj HMAC            │
  │                               │ 15. Atomowy nonce consume     │
  │                               │ 16. TTL ±10s                  │
  │                               │ 17. worldId/gameMode match    │
  │                               │ 18. OK → login                │
  │                               │     FAIL → disconnect         │
```

### 3.4 Pliki API do utworzenia/modyfikacji

| Plik | Opis | Status |
|------|------|--------|
| `login.php` | Główny endpoint logowania — dodać gameMode + launchToken, NIE generuje ticketu | ✅ DONE |
| `ticket.php` | **OSOBNY endpoint** — generowanie ticketu HMAC po wyborze postaci | ✅ DONE |
| `config.php` | Klucz tajny HMAC (`TICKET_SECRET`) | ✅ DONE |
| `ticket_nonces` (tabela DB) | Jednorazowe nonces — `nonce VARCHAR(64) PRIMARY KEY, expires_at INT` — konsumpcja przez atomowe DELETE | ✅ DONE |

### 3.5 Logika generowania ticketu na API (`ticket.php`)

**Walidacje autoryzacyjne w `ticket.php` (ZANIM wygeneruje ticket):**
1. Weryfikuj `sessionKey` — sesja istnieje i nie wygasła
2. Sprawdź `characterName` — **MUSI należeć do konta z tej sesji** (SELECT z tabeli players)
3. Sprawdź `worldId` — **MUSI być dozwolony dla `gameMode` zapisanego w sesji** (np. classic74 → tylko świat classic74)
4. Jeśli cokolwiek nie pasuje → `{"error": "Invalid request"}`

```php
function generateTicket($accountId, $characterName, $worldId, $gameMode, $clientIp, $keyStore) {
    $kid = $keyStore->getCurrentKeyId(); // np. "key-2026-03-a"
    $secret = $keyStore->getSecret($kid);
    
    $nonce = bin2hex(random_bytes(16));
    $issuedAt = time();
    $expiresAt = $issuedAt + 30; // 30 sekund — krótki TTL, ticket wydawany TUŻ przed connect
    
    $payload = json_encode([
        'kid' => $kid,
        'accountId' => $accountId,
        'characterName' => $characterName,
        'worldId' => $worldId,
        'gameMode' => $gameMode,
        'clientIp' => substr($clientIp, 0, strrpos($clientIp, '.')) . '.0/24',
        'nonce' => $nonce,
        'issuedAt' => $issuedAt,
        'expiresAt' => $expiresAt,
    ]);
    
    $signature = hash_hmac('sha256', $payload, $secret);
    
    // Zapisz nonce do bazy (jednorazowy)
    insertNonce($nonce, $expiresAt);
    
    return base64_encode($payload) . '.' . $signature;
}
```

### 3.6 Definicja sessionKey vs ticket — wyjaśnienie

W naszym systemie istnieją **dwa różne tokeny** o podobnych nazwach:

| Token | Kiedy powstaje | Format | TTL | Użycie |
|-------|---------------|--------|-----|--------|
| **sessionKey** (z login.php) | Po udanym loginie email+hasło | Opaque string (np. UUID lub `account\npassword`) | Czas sesji (np. 30min) | Identyfikuje sesję w API — klient wysyła go do `ticket.php` |
| **ticket** (z ticket.php) | Po wyborze postaci | `base64(payload).hmac_signature` | 30s | Klient wysyła do serwera gry (Canary) jako "sessionKey" w `protocolgame.cpp` |

**Ważne**: Pole `sessionKey` w protokole gry (TCP, linia ~820 protocolgame.cpp) przesyła **ticket**, nie oryginalny sessionKey z API. Nazwa jest myląca z powodu legacy kodu — w oryginalnym OTClient to pole nosiło nazwę `session key` i zawierało `account\npassword`.

Po naszej modyfikacji: klient Lua po wyborze postaci żąda ticketu z API i wstawia go w miejsce `sessionKey` w handshake z Canary.

---

## 4. KROK 3 — Serwer Canary: Weryfikacja ticketu 🟠 (guardy uszkodzone w canary_test/)

### 4.1 Gdzie w kodzie Canary

Aktualnie serwer auth działa tak (`protocolgame.cpp` linia ~820):
```cpp
std::string sessionKey = msg.getString();
// ... parsuje account\npassword z sessionKey
// ... wywołuje IOLoginData::gameWorldAuthentication(account, password, ...)
```

**Co dodać:**
1. Przed `gameWorldAuthentication` — sprawdzić czy sessionKey to ticket
2. Jeśli tak → zweryfikować podpis, TTL, nonce, worldId
3. Jeśli podpis OK → wyciągnąć accountId i characterName z ticketu
4. Jeśli podpis FAIL → disconnect z komunikatem

### 4.2 Plik: `src/server/network/protocol/protocolgame.cpp`

```cpp
// Po odczytaniu sessionKey (linia ~820):

// Nowy kod: Ticket validation
if (g_configManager().getBoolean(REQUIRE_TICKET)) {
    TicketResult ticketResult = validateTicket(sessionKey, characterName, getIP());
    if (!ticketResult.valid) {
        disconnectClient(ticketResult.errorMessage);
        return;
    }
    accountId = ticketResult.accountId;
    // Skip password check — ticket is the auth
} else {
    // Stary kod: password auth
    if (!IOLoginData::gameWorldAuthentication(...)) { ... }
}
```

### 4.3 Nowy plik: `src/server/security/ticket_validator.h/.cpp`

```cpp
struct TicketResult {
    bool valid = false;
    uint32_t accountId = 0;
    std::string characterName;
    std::string worldId;
    std::string gameMode;
    std::string errorMessage;
};

TicketResult validateTicket(
    const std::string& ticketString,
    const std::string& expectedCharacterName,
    uint32_t clientIP
);
```

**Logika walidacji:**
1. Rozdziel ticket na `payload_base64` + `signature_hex`
2. Zweryfikuj HMAC-SHA256 payload z `TICKET_SECRET` z config
3. Zdekoduj payload JSON
4. Sprawdź `expiresAt > now()`
5. Sprawdź `characterName == expectedCharacterName`
6. Sprawdź `worldId` pasuje do tego serwera
7. Sprawdź `nonce` nie był użyty (baza/pamięć)
8. Oznacz `nonce` jako użyty
9. Zwróć `accountId` z ticketu

### 4.4 Nowe klucze konfiguracji (`config.lua` serwera)

```lua
-- Ticket-gate security
requireTicket = true
ticketMaxAge = 30           -- sekund, max czas życia ticketu (= TTL z generateTicket)
ticketClockTolerance = 10   -- sekund, tolerancja driftu zegarów (±)
-- Efektywne okno akceptacji: 30 + 2×10 = 50s max
worldId = "classic74"       -- lub "modern" — identyfikator tego świata

-- Rotacja kluczy HMAC — serwer akceptuje WSZYSTKIE aktywne klucze
-- Klucze trzymane w pliku ENV lub osobnym secrets.lua (NIE w config.lua w repo!)
-- ticketKeys = {
--   ["key-2026-03-a"] = "AKTUALNY_KLUCZ_HMAC_256_MIN_32_ZNAKI",
--   ["key-2026-02-z"] = "POPRZEDNI_KLUCZ_WAZNY_JESZCZE_24H",
-- }
```

> **UWAGA**: `ticketKeys` powinny być ładowane z pliku `.env` lub `secrets.lua` (nie wersjonowanego w git). W `config.lua` zostawiamy tylko `requireTicket`, `ticketMaxAge`, `ticketClockTolerance`, `worldId`.

### 4.5 Pliki serwera do modyfikacji

> **UWAGA**: Pliki serwera znajdują się w `canary_test/src/` (GHA build target). Pierwotnie były w `canary/`, sportowane do `canary_test/` w commicie `98964825b`.

| Plik | Opis | Typ |
|------|------|-----|
| `canary_test/src/server/network/protocol/protocolgame.cpp` | Dodanie ticket validation przed auth + guardy D1-D10 | 🟠 WYMAGA POPRAWEK (guardy źle rozmieszczone) |
| `canary_test/src/server/network/protocol/ticket_validator.hpp` | Struktura i deklaracja | ✅ DONE |
| `canary_test/src/server/network/protocol/ticket_validator.cpp` | Implementacja walidacji HMAC + nonce | 🟠 DONE ale wymaga OpenSSL w CMake |
| `canary_test/src/config/configmanager.cpp` | Rejestracja `TICKET_GATE_ENABLED`, `TICKET_SECRET` | 🟠 DONE (brak `ticketMaxAge`, `ticketClockTolerance`, `worldId`) |
| `canary_test/config.lua.dist` | Dodanie nowych kluczy | 🟠 DONE (brak 3 kluczy) |
| `canary_test/src/server/CMakeLists.txt` | Dodanie ticket_validator.cpp do buildu | ✅ DONE |

---

## 5. KROK 4 — Feature flags Classic 7.4 🟠 (guardy D2-D7 źle rozmieszczone w canary_test/)

### 5.1 Lista flag

| Flaga | Modern | Classic 7.4 | Opis |
|-------|--------|-------------|------|
| `hotkeys_items` | ✅ | ❌ | Hotkey do użycia przedmiotu |
| `hotkeys_runes` | ✅ | ❌ | Hotkey do użycia runy |
| `hotkeys_spells` | ✅ | ✅ | Hotkey na zaklęcie (dozwolone w 7.4) |
| `action_bar` | ✅ | ❌ | Pasek szybkich akcji |
| `quick_loot` | ✅ | ❌ | Szybkie zbieranie łupu |
| `auto_loot` | ✅ | ❌ | Automatyczne zbieranie |
| `smart_equip` | ✅ | ❌ | Ctrl+klik equip |
| `container_sort` | ✅ | ❌ | Sortowanie w kontenerach |
| `market` | ✅ | ❌ | Market/giełda |
| `cyclopedia` | ✅ | ✅ | Encyklopedia (może być dozwolona) |
| `bestiary` | ✅ | ❌ | Bestiariusz (nowsza funkcja) |
| `wheel` | ✅ | ❌ | Koło umiejętności |
| `prey` | ✅ | ❌ | System Prey |

### 5.2 Gdzie sprawdzać flagi w kliencie

**Punkt 1: Hotkeys — blokada wykonania akcji**
- Plik: `modules/game_hotkeys/hotkeys.lua` (lub `game_hotkeys/hotkeys_manager.lua`)
- Przed wysłaniem `use item` / `use with`: sprawdź `CurrentGameMode.features.hotkeys_items`
- Komunikat: "Ta akcja jest niedostępna w trybie Classic 7.4"

**Punkt 2: Ładowanie modułów UI**
- Plik: `init.lua` lub `game_interface/gameinterface.lua`
- Jeśli `features.action_bar == false` → nie ładuj modułu `game_actionbar`
- Jeśli `features.market == false` → nie ładuj modułu `game_market`
- itd.

**Punkt 3: Item move/use**
- Plik: `modules/game_interface/gameinterface.lua` (lub `game_inventory/`)
- Przed `g_game.useInventoryItem()` / `g_game.move()`: sprawdź flagi
- Smart equip: zablokuj jeśli `features.smart_equip == false`

### 5.3 Walidacja na serwerze Canary (TWARDA BLOKADA — nie do obejścia przez klienta)

> **ZASADA**: Klient (Lua) to warstwa UX — informuje gracza, ukrywa przyciski.  
> **Serwer Canary (C++)** to warstwa BEZPIECZEŃSTWA — nawet zmodyfikowany klient nie przeskoczy tych blokad.  
> Każda zablokowana akcja musi być odrzucona PO STRONIE SERWERA.

#### 5.3.1 Jak serwer wie o trybie gracza

Ticket HMAC zawiera pole `gameMode` (np. `"classic74"` lub `"modern"`). Przy logowaniu serwer wyciąga tryb i zapisuje w obiekcie `Player`:

```cpp
// player.hpp — nowe pole
enum class GameMode : uint8_t {
    Modern = 0,
    Classic74 = 1,
};

class Player {
    // ...
    GameMode gameMode = GameMode::Modern;
public:
    GameMode getGameMode() const { return gameMode; }
    void setGameMode(GameMode mode) { gameMode = mode; }
    bool isClassic74() const { return gameMode == GameMode::Classic74; }
};
```

```cpp
// protocolgame.cpp — po walidacji ticketu (sekcja 4.2):
if (ticketResult.valid) {
    player->setGameMode(
        ticketResult.gameMode == "classic74" ? GameMode::Classic74 : GameMode::Modern
    );
}
```

#### 5.3.2 Blokada użycia run przez hotkey (USE ON CREATURE)

W trybie Classic 7.4 gracz **NIE może** użyć runy na stworzeniu przez hotkey. Może tylko: ręcznie przeciągnąć (drag) runę na cel lub kliknąć "Use with" z ręki.

**Problem**: Serwer nie wie wprost czy pakiet przyszedł z hotkey czy z ręcznego kliknięcia — to ten sam opcode (`parseUseWithCreature`, linia ~1195 protocolgame.cpp).

**Rozwiązanie — heurystyka server-side**:

```cpp
// protocolgame.cpp — w parseUseWithCreature() (linia ~1845)
void ProtocolGame::parseUseWithCreature(NetworkMessage &msg) {
    Position fromPos = msg.getPosition();
    uint16_t itemId = msg.get<uint16_t>();
    uint8_t fromStackPos = msg.getByte();
    uint32_t creatureId = msg.get<uint32_t>();

    // === CLASSIC 7.4: BLOKADA RUN NA HOTKEY ===
    if (player->isClassic74()) {
        const ItemType &itemType = Item::items[itemId];
        if (itemType.isRune()) {
            // Hotkey runy wysyła fromPos = {0xFFFF, 0, 0} (slot inventory)
            // lub fromPos z kontenera. W prawdziwym 7.4 runy używane z ręki
            // (slot hand) miały fromPos = inventory slot.
            //
            // TWARDA REGUŁA: w trybie classic74, runy mogą być użyte
            // TYLKO z pozycji ręki (slot 5 lub 6 = left/right hand)
            // lub z pozycji na ziemi/kontenera (ręczne "Use with")
            //
            // Hotkey zawsze wysyła fromPos.x == 0xFFFF z podejrzanym stackpos.
            // Blokujemy WSZYSTKIE "use rune on creature" z magic shortcut slot:
            if (fromPos.x == 0xFFFF && fromPos.y == 0 && fromPos.z == 0) {
                // To jest hotkey! Odrzuć.
                player->sendCancelMessage("W trybie Classic 7.4 nie możesz używać run przez hotkey.");
                return;
            }
        }
    }
    // ... reszta oryginalnego kodu ...
    g_game().playerUseWithCreature(player->getID(), fromPos, fromStackPos, creatureId, itemId);
}
```

**Alternatywna, bardziej restrykcyjna wersja** (blokuje KAŻDE "use rune on creature" — gracz musi rzucać runy na ziemię jak w prawdziwym 7.4):

```cpp
if (player->isClassic74()) {
    const ItemType &itemType = Item::items[itemId];
    if (itemType.isRune()) {
        player->sendCancelMessage("W trybie Classic 7.4 runy można używać tylko na ziemi.");
        return;
    }
}
```

#### 5.3.3 Blokada Quick Loot / Auto Loot

```cpp
// protocolgame.cpp — w parseQuickLoot() (linia ~1897)
void ProtocolGame::parseQuickLoot(NetworkMessage &msg) {
    if (player->isClassic74()) {
        player->sendCancelMessage("Quick Loot jest niedostępny w trybie Classic 7.4.");
        return; // ← ignoruj cały pakiet, nie czytaj dalej
    }
    // ... oryginalny kod ...
}

// Analogicznie w parseQuickLootBlackWhitelist() (linia ~1960):
void ProtocolGame::parseQuickLootBlackWhitelist(NetworkMessage &msg) {
    if (player->isClassic74()) {
        return; // cicha blokada — klient nie powinien tego wysyłać
    }
    // ...
}
```

#### 5.3.4 Blokada Market / Giełdy

```cpp
// protocolgame.cpp — blokada WSZYSTKICH operacji market:
// parseMarketLeave()    (linia ~1423)
// parseMarketBrowse()   (linia ~1426)
// parseMarketCreateOffer() (linia ~1429)
// parseMarketCancelOffer() (linia ~1432)
// parseMarketAcceptOffer() (linia ~1435)

// Najczyściej: dodać guard na początku każdej z tych metod:
void ProtocolGame::parseMarketBrowse(NetworkMessage &msg) {
    if (player->isClassic74()) {
        player->sendCancelMessage("Market jest niedostępny w trybie Classic 7.4.");
        return;
    }
    // ... oryginalny kod ...
}
// (powtórzyć dla pozostałych parseMarket* metod)
```

#### 5.3.5 Blokada Prey System

```cpp
// protocolgame.cpp — wszystkie parsePrey* metody:
// Analogicznie do Market — if (isClassic74()) return;
```

#### 5.3.6 Blokada Wheel of Destiny (Koło Umiejętności)

```cpp
// protocolgame.cpp — parseOpenWheel / parseWheelSaveData itp.:
// if (isClassic74()) return;
```

#### 5.3.7 Blokada Smart Equip (Ctrl+klik auto-equip)

```cpp
// Jeśli istnieje opcode dla "smart equip" → blokuj w trybie classic74
// W parseUseItem() (linia ~1827): jeśli akcja to auto-equip, blokuj
```

#### 5.3.8 Rate-limit na użycie run (dodatkowa warstwa anty-bot)

Nawet jeśli gracz używa run "legalnie" (z ręki), w prawdziwym 7.4 było ograniczenie:

```cpp
// player.cpp lub actions.cpp — przy useRune():
if (player->isClassic74()) {
    int64_t now = OTSYS_TIME();
    // Minimalne opóźnienie między użyciami run: 1000ms (jak w 7.4)
    if (now - player->lastRuneUse < 1000) {
        player->sendCancelMessage("Musisz chwilę poczekać.");
        return false;
    }
    player->lastRuneUse = now;
}
```

#### 5.3.9 Tabela podsumowująca — co blokuje klient, co serwer

> ⚠️ **UWAGA**: Poniższe "pewności" dotyczą **canary/** (referencja). W **canary_test/** guardy są uszkodzone — patrz sekcja 20.

| Funkcja | Klient (Lua) | Serwer (C++) | canary/ | canary_test/ |
|---------|-------------|-------------|---------|-------------|
| Hotkey na runę | Ukrywa opcję w UI | `parseUseWithCreature()` odrzuca runy z hotkey slot | ✅ OK | 🔴 brak guarda + złe zmienne |
| Quick Loot | Ukrywa przycisk | `parseQuickLoot()` → return | ✅ OK | 🔴 brak guarda (jest w złej metodzie) |
| Auto Loot | Ukrywa opcję | `parseQuickLoot()` → return | ✅ OK | 🔴 guard w `parseLookAt` zamiast właściwej |
| Market | Nie ładuje modułu | `parseMarket*()` → return | ✅ OK | 🔴 osierocony + brak w `parseMarketLeave` |
| Action Bar | Ukrywa pasek | Serwer ignoruje pakiety action bar | ✅ N/A | ✅ N/A |
| Prey | Ukrywa panel | `parsePrey*()` → return | ✅ OK | 🔴 guard w pętli bestiary |
| Wheel | Ukrywa panel | `parseWheel*()` → return | ✅ OK | ✅ OK |
| Smart Equip | Blokuje Ctrl+klik | Odrzuca auto-equip opcode | ✅ OK | 🔴 guard w `default:` case |
| Rune cooldown | Komunikat "poczekaj" | 1000ms min między użyciami | ✅ OK | ✅ OK |
| Bestiary | Ukrywa panel | Opcjonalnie: blokuj parseBestiary | ✅ OK | ✅ OK |

> **Wniosek**: W **canary/** guardy są poprawne. W **canary_test/** 6/10 guardów jest uszkodzonych — WYMAGA NAPRAWY przed buildem.

---

## 6. Kolejność implementacji (chronologicznie)

### Faza A — Klient UX (tydzień 1) — BEZ zmian serwera ✅ GOTOWE
| # | Zadanie | Trudność | Czas | Status |
|---|---------|----------|------|--------|
| A1 | Dodać `CLIENT_LOCKED` + `GameModes` do `init.lua` | ŁATWE | 30min | ✅ DONE (commit `72681f84c`) |
| A2 | Ekran wyboru trybu (gameModePanel) w `entergame.otui` | ŁATWE | 1h | ✅ DONE (commit `b216fe683`) |
| A3 | Logika wyboru trybu w `entergame.lua` + ustawienie serwera | ŚREDNIE | 2h | ✅ DONE (commit `b216fe683`) |
| A4 | Zablokować `ServerList.add/remove` gdy `CLIENT_LOCKED` | ŁATWE | 15min | ✅ DONE (commit `b216fe683`) |
| A5 | Ukryć pola serwera/portu/protokołu/http | ŁATWE | 30min | ✅ DONE (commit `b216fe683`) |
| A6 | Feature flags: blokada hotkey items/runes w kliencie | ŚREDNIE | 2h | ✅ DONE (hotkeys_manager.lua) |
| A7 | Feature flags: ukrycie modułów (action bar, market, itp.) | ŚREDNIE | 2h | ⬜ N/A — blokowane server-side (Faza D) |
| A8 | Testowanie na Windows | - | 2h | ⏳ CZEKA na GHA build |
| | **Suma fazy A** | | **~10h** | **6/8 DONE** |

### Faza B — API HTTP ticket-gate 2-fazowy (tydzień 2) ✅ GOTOWE
| # | Zadanie | Trudność | Czas | Status |
|---|---------|----------|------|--------|
| B1 | Dodać `gameMode` + `launchToken` do login.php | ŁATWE | 1h | ✅ DONE (login.php) |
| B2 | Filtrowanie worldów wg `gameMode` + zapisanie gameMode w sesji | ŁATWE | 1h | ✅ DONE (login.php) |
| B3 | **Nowy endpoint `ticket.php`** — walidacja sesji, sprawdzenie characterName∈konto, worldId∈gameMode, generowanie ticketu HMAC | ŚREDNIE | 4h | ✅ DONE (ticket.php) |
| B4 | Tabela `ticket_nonces` + `ticket_sessions` w MySQL | ŁATWE | 15min | ✅ DONE (schema_ticket_gate.sql) |
| B5 | Klient Lua: po wyborze postaci → request do ticket.php → użyj ticket jako sessionKey | ŚREDNIE | 3h | ✅ DONE (characterlist.lua + entergame.lua) |
| B6 | Klient C++: nowa metoda `requestTicket()` w httplogin.cpp/.h | ŚREDNIE | 2h | ✅ DONE (httplogin.cpp/h + luafunctions.cpp) |
| B7 | Testowanie flow: login → lista postaci → ticket → connect | - | 3h | ✅ DONE (smoke test CLI: HMAC verified) |
| | **Suma fazy B** | | **~14h** | **7/7 DONE** |

### Faza C — Serwer Canary ticket-gate (tydzień 3) 🟠 KOD GOTOWY, WYMAGA POPRAWEK GUARDÓW
| # | Zadanie | Trudność | Czas | Status |
|---|---------|----------|------|--------|
| C1 | Nowy plik `ticket_validator.cpp/.h` | ŚREDNIE | 4h | ✅ DONE (ticket_validator.hpp/cpp) |
| C2 | Integracja z `protocolgame.cpp` | ŚREDNIE | 3h | 🟠 DONE w canary/ — 🔴 USZKODZONE w canary_test/ |
| C3 | Nowe klucze w `configmanager.cpp` | ŁATWE | 1h | 🟠 DONE (brak 3 kluczy: ticketMaxAge, ticketClockTolerance, worldId) |
| C4 | Konfiguracja w `config.lua` | ŁATWE | 15min | 🟠 DONE (brak 3 kluczy w .dist) |
| C5 | Nonce store (in-memory lub DB) | ŚREDNIE | 2h | ✅ DONE (in-memory w ticket_validator.cpp) |
| C6 | Kompilacja i test | - | 3h | ⏳ CZEKA na naprawę guardów + GHA build |
| | **Suma fazy C** | | **~13h** | **3/6 ✅ + 2 🟠 + 1 ⏳** |

### Faza D — Feature flags serwer Canary (tydzień 4) 🟠 GUARDY USZKODZONE W canary_test/

> Wszystkie guardy opisane w sekcji 5.3. Tryb gracza pochodzi z ticketu HMAC (Faza C).
> ⚠️ **UWAGA**: Guardy w `canary/` są poprawne. W `canary_test/` port był uszkodzony — patrz sekcja 20.

| # | Zadanie | Trudność | Czas | Szczegóły (sekcja 5.3.x) | canary/ | canary_test/ |
|---|---------|----------|------|--------------------------|---------|-------------|
| D1 | `GameMode` enum + pole w `Player` + setter z ticketu | ŁATWE | 1h | 5.3.1 | ✅ | ✅ |
| D2 | Blokada rune-on-creature hotkey (`parseUseWithCreature`) | ŚREDNIE | 3h | 5.3.2 | ✅ | 🔴 złe zmienne + brak guarda w parseUseWithCreature |
| D3 | Blokada Quick Loot + Auto Loot (`parseQuickLoot*`) | ŁATWE | 1h | 5.3.3 | ✅ | 🔴 guard w złych metodach (parseUpdateContainer, parseLookAt) |
| D4 | Blokada Market — 5 metod `parseMarket*()` | ŁATWE | 1h | 5.3.4 | ✅ | 🔴 osierocony guard + brak w parseMarketLeave |
| D5 | Blokada Prey System (`parsePrey*`) | ŁATWE | 30min | 5.3.5 | ✅ | 🔴 guard w pętli bestiary |
| D6 | Blokada Wheel of Destiny (`parseWheel*`) | ŁATWE | 30min | 5.3.6 | ✅ | ✅ |
| D7 | Blokada Smart Equip (auto-equip opcode) | ŁATWE | 30min | 5.3.7 | ✅ | 🔴 guard w default: case zamiast parseHotkeyEquip |
| D8 | Rate-limit użycia run (1000ms cooldown classic74) | ŚREDNIE | 1.5h | 5.3.8 | ✅ | ✅ |
| D9 | Blokada Action Bar packets | ŁATWE | 30min | — | ⬜ N/A | ⬜ N/A |
| D10 | Blokada Bestiary (opcjonalne) | ŁATWE | 30min | 5.3.9 | ✅ | ✅ |
| D11 | Pełny test integracyjny | - | 4h | Tabela 5.3.9 | ⏳ CZEKA | ⏳ CZEKA |
| | **Suma fazy D** | | **~14h** | | **9/11 ✅** | **4/11 ✅ + 5 🔴** |

### Łączny szacunek: ~49h roboczych (5 tygodni)

---

## 7. Analiza istniejącego kodu — co już mamy

### 7.1 Klient — co można reuse

| Element | Plik | Co mamy | Co trzeba dodać |
|---------|------|---------|-----------------|
| `Servers_init` | `init.lua:13` | Zakomentowana definicja serwerów | Odkomentować + rozbudować o tryby |
| `setUniqueServer()` | `entergame.lua:914` | Ukrywa pola serwera/portu/protokołu | Reuse — wywoływać po wyborze trybu |
| `tryHttpLogin()` | `entergame.lua:668` | HTTP login z hostem | Dodać `gameMode` do request body |
| `loginSuccess()` | `entergame.lua:742` | Parsuje session + characters + worlds | Po wyborze postaci → request do `ticket.php` → użyj ticket jako sessionKey (2-fazowy flow, patrz sekcja 14) |
| `ServerList.add/remove` | `serverlist.lua:53/105` | Pełna obsługa listy serwerów | Dodać guard `CLIENT_LOCKED` |
| `g_crypt.encrypt/decrypt` | Corelib | Szyfrowanie credentials | Reuse dla ticket |
| `HTTP.post/postJSON` | `corelib/http.lua` | Pełna obsługa HTTP | Reuse |
| `g_gameConfig` | `meta.lua + C++` | Konfiguracja gry (fonty, sprite size) | Można dodać feature flags |

### 7.2 Serwer — co mamy

| Element | Plik | Co mamy | Co trzeba dodać |
|---------|------|---------|-----------------|
| `authType` | `config.lua:465` | `"password"` lub `"session"` | Dodać `"ticket"` |
| `sessionKey` parsing | `protocolgame.cpp:820-838` | Parsuje `account\npassword` | Alternatywna ścieżka: ticket parse |
| `IOLoginData::gameWorldAuthentication` | `ioLoginData.cpp` | Auth po email+password | Alternatywna auth po ticket |
| `ProtocolLogin::getCharacterList` | `protocollogin.cpp:32` | Wysyła listę postaci | Dodać filtr wg worldId/gameMode |
| `configmanager.cpp` | - | Rejestracja kluczy konfiguracji | Dodać `REQUIRE_TICKET`, `TICKET_SECRET` |

### 7.3 API HTTP — co mamy

| Element | Lokalizacja | Status |
|---------|------------|--------|
| `login.php` | WWW serwer | Istnieje — obsługuje login + character list |
| MySQL (accounts, players) | Baza danych | Istnieje |
| MyAcc panel | WWW | Istnieje |

---

## 8. Ryzyka i mitygacje

| Ryzyko | Prawdop. | Wpływ | Mitygacja |
|--------|----------|-------|-----------|
| Ktoś patchuje binarkę klienta | ŚREDNIE | Wysoki | Ticket-gate na serwerze — bez ticketu i tak nie wejdzie |
| Ktoś przechwytuje ticket (MITM) | NISKIE | Wysoki | **HTTPS obowiązkowe** + TTL 30s + nonce jednorazowy + docelowo cert pinning |
| Ktoś pisze własny klient | NISKIE | Wysoki | Ticket = wymaga przejścia przez API → utrudnione |
| Ticket secret wycieknie | NISKIE | Krytyczny | Rotacja kluczy z `kid`, mapa aktywnych kluczy (current + previous 24h), secrets w .env |
| Komplikacje z kompilacją serwera C++ | ŚREDNIE | Średni | Ticket validator to prosty plik, minimalne zależności |
| Gracz zmienia tryb po zalogowaniu | ŚREDNIE | Średni | Ticket ma `gameMode` — serwer odrzuci jeśli niezgodny |

---

## 9. Zależności zewnętrzne

| Zależność | Do czego | Czy mamy |
|-----------|---------|----------|
| OpenSSL / libcrypto | HMAC-SHA256 w C++ (serwer) | ✅ TAK — dodano `openssl` do vcpkg.json + `OpenSSL::Crypto` w CanaryLib.cmake (`dfe1a8784`) |
| json library (C++) | Parsowanie ticketu na serwerze | ✅ TAK — Canary używa nlohmann/json |
| PHP hash_hmac | Generowanie ticketu w API | ✅ TAK — wbudowane w PHP |
| MySQL | Tabela nonces | ✅ TAK — istniejąca baza |

---

## 10. Docelowy test akceptacyjny

> ⚠️ **STATUS**: To są **docelowe scenariusze testowe** — większość NIE ZOSTAŁA jeszcze przetestowana (brak działającego builda).

| # | Scenariusz | KOD | TEST |
|---|-----------|-----|------|
| 1 | Gracz uruchamia klienta → widzi ekran wyboru trybu | ✅ | ⏳ |
| 2 | Wybiera "Classic 7.4" → wypełnia login → loguje się | ✅ | ⏳ |
| 3 | Widzi TYLKO postaci z serwera 7.4 (filtrowanie worldów) | ✅ | ⏳ |
| 4 | Nie ma opcji dodania/edycji serwera | ✅ | ⏳ |
| 5 | Na serwerze 7.4: hotkey na runę → komunikat "niedostępne" | 🟠 | ⏳ |
| 6 | Na serwerze 7.4: brak action bar, quick loot, market | 🟠 | ⏳ |
| 7 | Gracz z innego klienta (np. czysty OTClient) → odrzucona (brak ticketu) | ✅ | ⏳ |
| 8 | Stary ticket (>30s) → odrzucony | ✅ | ⏳ |
| 9 | Ten sam ticket użyty 2x → odrzucony (nonce) | ✅ | ⏳ |
| 10 | Gracz w trybie "Modern" → nie łączy się z serwerem 7.4 | ✅ | ⏳ |

---

---

## 11. Wymagania bezpieczeństwa produkcyjnego

> Sekcja dodana po review — adresuje luki w pierwotnym planie.

### 11.1 HTTPS jako wymóg twardy (nie opcja)

- **API login WYŁĄCZNIE po HTTPS** (port 443, TLS 1.2+). Żadnego HTTP.
- W `GameModes.servers` URL-e MUSZĄ zaczynać się od `https://`.
- Serwer HTTP (port 80) → redirect 301 na HTTPS lub brak nasłuchu.
- **Docelowo**: certificate pinning w kliencie (pin SPKI hash klucza publicznego).  
  - Implementacja: w C++ (`g_http`) dodać weryfikację fingerprint certyfikatu.  
  - Fallback: jeśli pin się nie zgadza → odrzucenie połączenia + komunikat "Nieznany certyfikat".
  - Pin aktualizowany przy nowej wersji klienta.
- **Bez HTTPS**: ticket wycieka przez MITM/proxy, odpowiedzi API mogą być podmieniane.

### 11.2 Rotacja kluczy HMAC (`kid`)

Ticket zawiera pole `kid` (key-id) identyfikujące którym kluczem go podpisano:

```
Serwer trzyma mapę aktywnych kluczy:
  key-2026-03-a  →  "bieżący klucz"        (podpisuje + akceptuje)
  key-2026-02-z  →  "poprzedni klucz"      (tylko akceptuje, max 24h)
```

**Procedura rotacji:**
1. Wygeneruj nowy klucz, dodaj do mapy na API + serwerze jako `current`
2. Stary klucz przechodzi na `previous` (akceptowalny jeszcze 24h)
3. Po 24h — usuń stary klucz z mapy
4. Żadnego downtime, żaden gracz nie traci sesji

**Kiedy rotować:**
- Planowo: co 30-90 dni
- Awaryjnie: natychmiast po podejrzeniu wycieku

### 11.3 Twarde odcięcie alternatywnych ścieżek logowania

Jeśli `requireTicket = true`:

| Ścieżka | Zachowanie |
|---------|------------|
| `protocolgame.cpp` (game port 7172) | Wymaga ticket → OK |
| `protocollogin.cpp` (login port 7171) | **ODRZUCA wszystkie połączenia** lub zwraca pustą listę postaci |
| Bezpośrednie wpisanie hasła (stary OTC) | **ODRZUCONE** — brak ticketu = disconnect |
| `authType = "password"` | **WYŁĄCZONE** — jedyny akceptowany authType to `"ticket"` |

**Implementacja:**
- `protocollogin.cpp::onRecvFirstMessage()` → jeśli `REQUIRE_TICKET` → `disconnectClient("Use official client")` i `return`
- `protocolgame.cpp` → jedyna akceptowana ścieżka to ticket validation
- Config: `authType = "ticket"` (nowa wartość, zamiast "password" / "session")

### 11.4 Nonce storage — strategia i czyszczenie

**Tabela MySQL:**
```sql
CREATE TABLE ticket_nonces (
    nonce VARCHAR(64) PRIMARY KEY,
    expires_at INT UNSIGNED NOT NULL,
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB;
```

> **UWAGA**: Tabela NIE ma kolumny `used_at`. Nonce jest **usuwany** przy konsumpcji (atomowe DELETE), nie oznaczany.

**Walidacja (ATOMOWA — jedno zapytanie):**
```sql
DELETE FROM ticket_nonces WHERE nonce = ? AND expires_at > UNIX_TIMESTAMP()
-- Sprawdź affected_rows:
--   1 → nonce ważny, skonsumowany → ACCEPT
--   0 → nie istnieje lub wygasły → REJECT (replay/expired)
```

> Jedno `DELETE` z warunkiem jest atomowe — nie ma race condition (TOCTOU) jak przy SELECT+UPDATE.

**Czyszczenie wygasłych (cleanup):**
- Cron co 15 minut: `DELETE FROM ticket_nonces WHERE expires_at < UNIX_TIMESTAMP()`
- Alternatywnie: MySQL event scheduler
- Rozmiar tabeli: przy 100 loginów/min × 30s TTL = max ~3000 wierszy (marginalne)
- Po restarcie serwera: nonce w DB — działa bez utraty stanu

**Opcja in-memory (serwer Canary, dla wydajności):**
```cpp
// ticket_validator.cpp
std::mutex nonceMutex;
std::unordered_set<std::string> validNonces; // ładowane z DB na start

bool consumeNonce(const std::string& nonce) {
    std::lock_guard<std::mutex> lock(nonceMutex);
    return validNonces.erase(nonce) > 0; // atomowe: true=OK, false=replay
}
```
- Cleanup co 60s w `Dispatcher::addEvent()` — usuń wygasłe
- Hybrid: DB jako persistent store, memory jako fast-path

### 11.5 Tolerancja zegarów (clock drift)

Serwer i API mogą mieć drobny drift zegarów (1-10s). Walidacja TTL:

```cpp
bool isTicketTimeValid(int64_t issuedAt, int64_t expiresAt) {
    int64_t now = std::time(nullptr);
    int64_t tolerance = g_configManager().getNumber(TICKET_CLOCK_TOLERANCE); // 10s
    
    return (now >= issuedAt - tolerance) && (now <= expiresAt + tolerance);
}
```

### 11.6 Wiązanie ticketu do kontekstu (context binding)

Opcjonalne wzmocnienia (soft-check, nie hard-block):

| Pole | Walidacja | Blokuje? | Cel |
|------|-----------|----------|-----|
| `clientIp` (/24 maska) | Porównaj z IP łączącego | Nie (log + metryka) | Wykrywanie ticket theft |
| `clientHash` | Porównaj z nagłówkiem klienta | Nie (log + metryka) | Wykrywanie zmodyfikowanego klienta |
| `worldId` | MUSI pasować do serwera | **TAK** (hard block) | Izolacja trybów |
| `gameMode` | MUSI pasować | **TAK** (hard block) | Izolacja trybów |
| `characterName` | MUSI pasować | **TAK** (hard block) | Ochrona przed podmianą postaci |

> **`clientHash` NIE jest zabezpieczeniem** — da się go podrobić w zmodyfikowanym kliencie. Traktować jako sygnał do analizy / telemetrii.

### 11.7 Rate limiting i ochrona brute-force

**Na poziomie API HTTP:**

| Endpoint | Limit | Blokada |
|----------|-------|---------|
| `POST /login.php` | 5 req/min per IP | Ban IP na 15 min po 10 nieudanych |
| `POST /login.php` | 3 req/min per account | Ban account na 5 min po 5 nieudanych |
| Ticket generation | 2 req/min per account | Soft limit (nie blokuj loginu, tylko ticket) |

**Implementacja PHP:**
```php
// Redis/Memcached counter
$key = 'login_attempts:' . $clientIp;
$attempts = $redis->incr($key);
$redis->expire($key, 60);
if ($attempts > 5) {
    http_response_code(429);
    die(json_encode(['error' => 'Too many attempts. Try again later.']));
}
```

**Na poziomie serwera Canary:**
- Już istnieje: ban check w `protocolgame.cpp` (IP ban table)
- Dodać: rate limit na invalid tickets (>5 invalid z jednego IP → temp ban)

### 11.8 Observability — logi, metryki, alerty

**Logi (serwer Canary):**
Każde odrzucenie ticketu musi być zalogowane z powodem:
```
[TICKET] REJECT ip=83.12.44.55 reason=expired nonce=abc123 account=12345
[TICKET] REJECT ip=83.12.44.55 reason=invalid_signature kid=key-2026-03-a
[TICKET] REJECT ip=83.12.44.55 reason=replay_nonce nonce=abc123
[TICKET] REJECT ip=83.12.44.55 reason=world_mismatch ticket_world=modern server_world=classic74
[TICKET] REJECT ip=83.12.44.55 reason=no_ticket (bare OTC client)
[TICKET] OK     ip=83.12.44.55 account=12345 char=PlayerOne world=classic74
```

**Metryki:**
- Liczba ticketów: OK vs REJECT (per reason)
- Latencja walidacji ticketu (ms)
- Rozmiar tabeli nonces
- Liczba unikalnych IP z invalid_signature (sygnał ataku)

**Alerty:**
- >50 invalid_signature z jednego /24 w 5 min → alert + auto-ban subnet
- >20 replay_nonce per account w 1h → alert (ktoś próbuje replay)
- >100 no_ticket w 15 min z jednego IP → prawdopodobnie skaner/bot

### 11.9 Uwaga o `protocol = 1420` w GameModes

Pole `protocol` w `GameModes` jest informacyjne — oba tryby (Modern i Classic 7.4) używają tego samego protokołu sieciowego OTClient (1420). Tryb 7.4 to **emulacja rozgrywki**, nie zmiana protokołu. Nie sugerować, że Classic 7.4 używa starego protokołu.

---

## 12. Zaktualizowana kolejność implementacji (z uwzględnieniem sekcji 11)

### Priorytet 1 (razem z Fazą A/B):
1. **HTTPS w konfiguracji** — zmiana URL-i na `https://`, certyfikat Let's Encrypt
2. **Rotacja kluczy (`kid`)** — od razu w formacie ticketu
3. **Twarde odcięcie ProtocolLogin** gdy `requireTicket = true`

### Priorytet 2 (razem z Fazą C):
4. **Nonce storage z cleanup** — tabela + cron/event
5. **Tolerancja zegarów** (±10s) w walidacji
6. **Rate limiting** na API login

### Priorytet 3 (po MVP, tydzień 5):
7. **Logi/metryki** odrzuceń ticketów
8. **Certificate pinning** w kliencie (C++)
9. **Context binding** (clientIp, clientHash) jako soft-check
10. **Alerty** na anomalie

---

## 13. Weryfikacja kodu — błędy w planie wykryte po audycie (Codex review)

> Sekcja dodana po głębokim audycie kodu źródłowego klienta i serwera.  
> Każdy punkt poniżej został **zweryfikowany** ręcznie w kodzie.

### 13.1 ❗ KRYTYCZNE: Ticket wydawany za wcześnie (przed wyborem postaci)

**Problem:**  
Plan zakłada, że ticket jest wydawany w odpowiedzi na `POST /login.php` i zawiera `characterName` + `worldId`. Ale gracz wybiera postać **dopiero POTEM** (na `characterlist`). W momencie loginu nie wiadomo jeszcze, kim będzie grał.

**Dowód w kodzie:**
- `entergame.lua:668-728`: `tryHttpLogin()` → API zwraca listę postaci + session
- `entergame.lua:742`: `loginSuccess()` → wyświetla listę postaci (`CharacterList.create()`)
- `characterlist.lua`: gracz wybiera postać → dopiero wtedy `g_game.loginWorld()`

**Rozwiązanie — 2-fazowy ticket:**
```
FAZA 1 — LOGIN (login.php):
  Klient: POST {email, password, gameMode}
  API:    → session + characters + worlds (przefiltrowane)
          → BEZ TICKETU (jeszcze nie wiadomo kto gra)

FAZA 2 — TICKET (ticket.php, NOWY endpoint):
  Klient: POST {sessionKey, characterName, worldId}
  API:    → weryfikuje session
          → generuje ticket z characterName + worldId
          → zwraca ticket

FAZA 3 — CONNECT:
  Klient: g_game.loginWorld(..., sessionKey=ticket)
  Serwer: → weryfikuje ticket → wpuszcza
```

**Pliki do modyfikacji:**
- `login.php` — BEZ zmian (wydaje sesję, NIE ticket)
- `ticket.php` — **NOWY** endpoint, wydaje ticket po wyborze postaci
- `entergame.lua` lub `characterlist.lua` — po wyborze postaci → request do `ticket.php`
- `httplogin.cpp`/`.h` — nowa metoda `requestTicket(sessionKey, characterName, worldId)`

**Wpływ:** Zmienia całą sekcję 3.3 (przepływ logowania). Ticket jest wydawany MIĘDZY wyborem postaci a połączeniem z game serverem.

### 13.2 ❗ KRYTYCZNE: TLS wyłączony w kliencie C++ — HTTPS jest iluzją

**Problem:**  
W `httplogin.cpp` TLS jest **celowo wyłączony**, a jest też fallback na plain HTTP:

```cpp
// httplogin.cpp, loginHttpsJson():
client.set_ca_cert_path("./cacert.pem");
client.enable_server_certificate_verification(false);  // ← TLS WYŁĄCZONY!
```

Dodatkowo w `httpLogin()`:
```cpp
httplib::Result result = this->loginHttpsJson(host, path, port, email, password);
if (httpLogin && (!result || result->status != Success)) {
    result = loginHttpJson(host, path, port, email, password);  // ← FALLBACK NA HTTP!
}
```

To oznacza:
1. Certyfikat serwera NIE jest walidowany → MITM trywialny
2. Jeśli HTTPS się nie uda (np. ktoś blokuje port 443) → klient automatycznie idzie po HTTP
3. Ticket przesłany HTTPS jest tak samo narażony jak plain text

**Rozwiązanie — wymagane zmiany w C++:**
1. `enable_server_certificate_verification(true)` — MUSI BYĆ `true`
2. Dołączyć `cacert.pem` z aktualnymi certyfikatami CA (lub system store)
3. **Usunąć fallback na HTTP** z `httpLogin()` — jeśli HTTPS failuje → error, nie HTTP
4. Docelowo: cert pinning (hardcode SPKI hash)

**Pliki:**
- `testyy/src/framework/net/httplogin.cpp` linia ~216 (SSL verification) + linia ~108 (fallback)

### 13.3 ⚠️ WYSOKIE: ServerList bypass przez ręczną edycję settings

**Problem:**  
Plan blokuje `ServerList.add()` i `ServerList.remove()`, ale `ServerList.init()` wpierw ładuje serwery z pliku ustawień:

```lua
-- serverlist.lua:14
servers = g_settings.getNode('ServerList') or {}
```

A `ServerList.load()` wywołuje `ServerList.add(host, ..., true)` z flagą `load=true`, co **omija guard** `CLIENT_LOCKED`:
```lua
-- Obecny plan (sekcja 2.2 C):
function ServerList.add(host, port, protocol, httpLogin, load)
    if CLIENT_LOCKED and not load then  -- ← load=true OMIJA BLOKADĘ
        return false
    end
```

Gracz może ręcznie dopisać wpisy do pliku `settings.json` / `settings.otml` → zostaną załadowane.

**Rozwiązanie:**
```lua
function ServerList.init()
    if CLIENT_LOCKED then
        -- TYLKO Servers_init, IGNORUJ g_settings
        servers = {}
        if Servers_init then
            for key, value in pairs(Servers_init) do
                servers[key] = value
            end
        end
    else
        servers = g_settings.getNode('ServerList') or {}
        if Servers_init then
            for key, value in pairs(Servers_init) do
                if not servers[key] then servers[key] = value end
            end
        end
    end
    if servers then ServerList.load() end
end

-- Także: zablokować zapisywanie settings gdy locked
function ServerList.terminate()
    if not CLIENT_LOCKED then
        g_settings.setNode('ServerList', servers)
    end
end
```

### 13.4 ✅ NAPRAWIONE: Nonce race condition (TOCTOU)

**Problem (stary plan, sekcja 11 przed korektą):**  
Plan opisywał walidację nonce jako SELECT + UPDATE (dwa osobne zapytania, podatne na TOCTOU). Zostało to naprawione w sekcji 11.4.

**Rozwiązanie (zastosowane w sekcji 11.4):**
```sql
-- Jedna atomowa operacja:
DELETE FROM ticket_nonces 
WHERE nonce = ? AND expires_at > UNIX_TIMESTAMP()
-- Sprawdź affected_rows: jeśli 1 → OK, jeśli 0 → odrzuć
```

> Tabela ticket_nonces NIE ma kolumny `used_at`. Nonce jest usuwany przy konsumpcji.

**Lub w C++ (in-memory, lock-free):**
```cpp
// std::unordered_set z mutex lub concurrent_hash_map
std::mutex nonceMutex;
std::unordered_set<std::string> validNonces;  // załadowane z DB

bool consumeNonce(const std::string& nonce) {
    std::lock_guard<std::mutex> lock(nonceMutex);
    return usedNonces.insert(nonce).second; // true jeśli nowy, false jeśli replay
}
```

### 13.5 ⚠️ WYSOKIE: authType="ticket" wymaga nowej ścieżki w C++

**Problem:**  
Aktualnie `protocolgame.cpp` ma tylko 2 ścieżki:
```cpp
// protocolgame.cpp:824
std::string authType = g_configManager().getString(AUTH_TYPE);
if (authType != "session") {
    // → parsuje account\npassword z sessionKey
}
// ... potem:
// protocolgame.cpp:913
IOLoginData::gameWorldAuthentication(accountDescriptor, password, characterName, accountId, ...)
```

Wpisanie `authType = "ticket"` do config.lua **nie zmieni nic** — bo `"ticket" != "session"` → wpadnie w ścieżkę password → spróbuje sparsować ticket jako `email\npasswd` → FAIL.

**Rozwiązanie — nowa ścieżka:**
```cpp
if (authType == "ticket") {
    // Nowa ścieżka: ticket validation
    TicketResult ticketResult = validateTicket(sessionKey, characterName, getIP());
    if (!ticketResult.valid) {
        disconnectClient(ticketResult.errorMessage);
        return;
    }
    accountId = ticketResult.accountId;
    // Skip password auth — ticket IS the auth
} else if (authType != "session") {
    // Stara ścieżka: password
    size_t pos = sessionKey.find('\n');
    // ... parsowanie account\npassword
}
```

**Pliki:**
- `protocolgame.cpp` linia ~824-935 — główna zmiana
- `configmanager.cpp` — rejestracja `REQUIRE_TICKET`, `TICKET_SECRET`, `WORLD_ID`
- Nowy `ticket_validator.cpp/.h`

### 13.6 ⚠️ WYSOKIE: gameMode brakuje w request body klienta C++

**Problem:**  
Plan mówi "dodaj `gameMode` do request body HTTP", ale budowanie body jest w C++:

```cpp
// httplogin.cpp, loginHttpsJson():
const json body = { {"email", email}, {"password", password}, 
                    {"stayloggedin", true}, {"type", "login"} };
```

Nie ma pola `gameMode`. Aby je dodać, trzeba:
1. Zmienić sygnaturę `httpLogin()`, `loginHttpsJson()`, `loginHttpJson()` — dodać parametr `gameMode`
2. Zmienić `httplogin.h` — dodać parametr w deklaracjach
3. Zmienić Lua binding — by Lua mogło przekazać gameMode do C++

**Rozwiązanie:**
```cpp
// httplogin.h — nowa sygnatura:
void httpLogin(const std::string& host, const std::string& path,
               uint16_t port, const std::string& email,
               const std::string& password, int request_id, bool httpLogin,
               const std::string& gameMode = "");

// httplogin.cpp — body z gameMode:
const json body = { {"email", email}, {"password", password}, 
                    {"stayloggedin", true}, {"type", "login"},
                    {"gameMode", gameMode} };
```

**Pliki:**
- `testyy/src/framework/net/httplogin.h` — sygnatura
- `testyy/src/framework/net/httplogin.cpp` — body JSON + sygnatura
- Lua binding file (prawdopodobnie `luafunctions.cpp` lub `lua_http.cpp`) — dodać parametr

### 13.7 ✅ NAPRAWIONE: TTL ticketu ujednolicony na 30s

**Problem (stary plan):**  
Różne sekcje podawały różne TTL: 30s, 120s, 300s. To mogło prowadzić do rozbieżnych implementacji.

**Rozwiązanie (zastosowane):**  
- **TTL ticketu = 30 sekund** wszędzie (generateTicket, config.lua, testy)
- Ticket wydawany TUŻ przed connect (2-faza: wybór postaci → ticket → connect powinno trwać <5s)
- `ticketClockTolerance = 10s` daje efektywne okno 30 + 2×10 = 50s
- 30s wystarczy nawet dla wolnego internetu (ticket → connect to jedne pakiety TCP)

### 13.8 ⚡ ŚREDNIE: Hasła/tickety logowane w plaintext

**Problem:**  
`httplogin.cpp` Logger() wypisuje pełne body request i response:
```cpp
void LoginHttp::Logger(const auto& req, const auto& res) {
    std::cout << req.body << std::endl;    // ← HASŁO W PLAINTEXT
    std::cout << res.body << std::endl;    // ← SESSION/TICKET W PLAINTEXT
}
```

**Rozwiązanie:**
- Usunąć Logger z produkcji (lub schować za `#ifdef DEBUG`)
- Jeśli zostawić: redagować pola `password`, `sessionkey`, `ticket` w body
- Alternatywnie: `client.set_logger(nullptr)` w release builds

### 13.9 ⚡ ŚREDNIE: OpenSSL NIE jest linkowany w Canary

**Problem:**  
Plan twierdzi "TAK — Canary już linkuje OpenSSL" ale to **NIEPRAWDA**:

**`CanaryLib.cmake` linkuje:**
- GMP, LuaJIT, CURL, ZLIB, abseil, asio, fmt, nlohmann_json, protobuf, pugixml, spdlog, argon2, mariadb
- **NIE MA OpenSSL::Crypto ani OpenSSL::SSL**

**RSA w Canary używa GMP** (nie OpenSSL):
```cpp
// rsa.hpp: 
mpz_t n {};  // ← GMP, nie EVP_PKEY
mpz_t d {};
```

**HMAC w tools.cpp** to ręczna implementacja SHA1-HMAC (TOTP authenticator), nie OpenSSL.

**Rozwiązanie — 3 opcje (od najłatwiejszej):**

1. **Użyć CURL (już linkowany) jako transitive dep** — CURL zazwyczaj zależy od OpenSSL, ale to jest implementation detail, niebezpieczne do polegania

2. **Dodać OpenSSL jawnie:**
   ```json
   // vcpkg.json — dodać:
   "openssl"
   ```
   ```cmake
   // CanaryLib.cmake — dodać:
   find_package(OpenSSL REQUIRED)
   target_link_libraries(${PROJECT_NAME}_lib PUBLIC OpenSSL::Crypto)
   ```

3. **Ręczna implementacja HMAC-SHA256** bez OpenSSL (jak TOTP w tools.cpp, ale SHA256 zamiast SHA1) — ale to ryzyko błędów kryptograficznych

**Rekomendacja:** Opcja 2 (jawny OpenSSL) — najpewniejsza i najbardziej standardowa.

---

## 14. Poprawiony przepływ logowania (2-fazowy ticket)

```
KLIENT                         API HTTP                        SERWER CANARY
  │                               │                               │
  │ 1. POST /login.php (HTTPS!)   │                               │
  │    {email, password, gameMode} │                               │
  │ ─────────────────────────────>│                               │
  │                               │ 2. Weryfikuj email+hasło      │
  │                               │ 3. Pobierz listę postaci      │
  │                               │ 4. Filtruj worldy wg gameMode │
  │                               │ 5. Wydaj session (BEZ ticketu)│
  │ 6. Odpowiedź:                 │                               │
  │    {session, characters,      │                               │
  │     worlds (filtered)}        │                               │
  │ <─────────────────────────────│                               │
  │                               │                               │
  │ 7. Gracz wybiera postać       │                               │
  │                               │                               │
  │ 8. POST /ticket.php (HTTPS!)  │                               │
  │    {sessionKey, characterName,│                               │
  │     worldId}                  │                               │
  │ ─────────────────────────────>│                               │
  │                               │ 9. Weryfikuj session          │
  │                               │ 10. Generuj ticket            │
  │                               │     (HMAC + nonce + TTL)      │
  │ 11. Odpowiedź:                │                               │
  │    {ticket: "base64.signature"}│                               │
  │ <─────────────────────────────│                               │
  │                               │                               │
  │ 12. g_game.loginWorld(        │                               │
  │      ..., sessionKey=ticket)  │                               │
  │ ──────────────────────────────┼──────────────────────────────>│
  │                               │                               │
  │                               │ 13. Weryfikuj ticket (HMAC)  │
  │                               │ 14. Sprawdź nonce (atomowy)  │
  │                               │ 15. Sprawdź TTL ±10s         │
  │                               │ 16. Sprawdź worldId/gameMode │
  │                               │ 17. OK → login               │
  │                               │     FAIL → disconnect        │
```

---

## 15. Zaktualizowana estymacja (po audycie)

### Dodatkowe zadania wynikające z audytu:

| # | Zadanie | Trudność | Czas | Faza | Status |
|---|---------|----------|------|------|--------|
| X1 | 2-fazowy ticket: endpoint `ticket.php` + klient Lua/C++ | WYSOKIE | 6h | B | ✅ DONE |
| X2 | Włączenie TLS verification + usunięcie HTTP fallback w `httplogin.cpp` | ŚREDNIE | 2h | A | ✅ DONE |
| X3 | Pełna blokada `ServerList.init()` — ignoruj `g_settings` gdy locked | ŁATWE | 1h | A | ✅ DONE |
| X4 | Atomowy nonce (DELETE z affected_rows lub mutex) | ŁATWE | 1h | C | ✅ DONE |
| X5 | Nowa ścieżka `authType="ticket"` w `protocolgame.cpp` | WYSOKIE | 4h | C | ✅ DONE |
| X6 | Dodanie `gameMode` do `httpLogin()` C++ + Lua binding | ŚREDNIE | 3h | A | ✅ DONE |
| X7 | Usunięcie logowania haseł/ticketów w `httplogin.cpp` | ŁATWE | 30min | A | ✅ DONE |
| X8 | Dodanie OpenSSL do vcpkg.json + CanaryLib.cmake | ŁATWE | 30min | C | ✅ DONE (`dfe1a8784` — openssl w vcpkg.json + find_package+OpenSSL::Crypto w CMake) |
| | **Suma dodatkowych zadań** | | **~18h** | | **8/8 DONE ✅** |

### Nowy łączny szacunek (Fazy A-D + audyt): ~63h roboczych

---

## 16. FAZA E — Launcher z auto-update

### 16.1 Co robi launcher

```
┌───────────────────────────────────────────────────────┐
│                    LAUNCHER.EXE                       │
│                                                       │
│  1. Sprawdź wersję launchera                         │
│     GET /api/launcher-version.php                     │
│     → Jeśli nowsza → pobierz nowy launcher            │
│                                                       │
│  2. Pobierz manifest plików klienta                  │
│     GET /api/update.php?channel=stable                │
│     → { "version": "1.4.2",                          │
│         "files": [                                    │
│           {"path": "otclient.exe",                    │
│            "sha256": "abc123...",                     │
│            "size": 15728640,                          │
│            "url": "/files/otclient.exe"},             │
│           {"path": "data/things/tibia.dat",           │
│            "sha256": "def456...",                     │
│            "size": 52428800,                          │
│            "url": "/files/data/things/tibia.dat"},    │
│           ...                                         │
│         ]}                                            │
│                                                       │
│  3. Porównaj lokalne hashe z manifestem               │
│     → Nowe/zmienione pliki → pobierz                  │
│     → Usunięte pliki → skasuj lokalnie                │
│     → Zmodyfikowane pliki → nadpisz (anty-cheat)      │
│     → Pasek postępu: "Aktualizacja 3/12 plików..."    │
│                                                       │
│  4. Weryfikacja integralności po pobraniu             │
│     → sha256 pobranego == sha256 z manifestu?         │
│     → Jeśli nie → ponów pobieranie (max 3 próby)      │
│                                                       │
│  5. Pobierz launch-token z API                        │
│     POST /api/launcher-token.php                      │
│     {launcherVersion, filesHash}                      │
│     → {launchToken: "uuid-jednorazowy", expiresIn:300}│
│     (token wiązany z IP klienta przy wydaniu I konsum.)│
│                                                       │
│  6. Uruchom klienta                                   │
│     env OTC_LAUNCH_TOKEN=uuid otclient.exe            │
│     (token przez env, NIE przez CLI argument!)         │
│                                                       │
│  7. Monitoruj proces klienta (opcjonalnie)            │
│     → Jeśli klient crashuje → pokaż log + zgłoś      │
└───────────────────────────────────────────────────────┘
```

### 16.2 Przepływ pełny (launcher → klient → API → serwer)

```
GRACZ              LAUNCHER            API HTTP              KLIENT            SERWER CANARY
  │                   │                   │                    │                    │
  │ Klik "Graj"      │                   │                    │                    │
  │ ─────────────────>│                   │                    │                    │
  │                   │ GET /update.php   │                    │                    │
  │                   │ ─────────────────>│                    │                    │
  │                   │ manifest plików   │                    │                    │
  │                   │ <─────────────────│                    │                    │
  │                   │                   │                    │                    │
  │  "Sprawdzanie     │ porównaj hashe    │                    │                    │
  │   plików..."      │ pobierz update    │                    │                    │
  │ <─────────────────│ ═══════════════>  │                    │                    │
  │                   │                   │                    │                    │
  │  "Aktualizacja    │ POST /launcher-   │                    │                    │
  │   zakończona"     │ token.php         │                    │                    │
  │                   │ ─────────────────>│                    │                    │
  │                   │ {launchToken}     │                    │                    │
  │                   │ <─────────────────│                    │                    │
  │                   │                   │                    │                    │
  │                   │ uruchom otclient  │                    │                    │
  │                   │ env TOKEN=X       │                    │                    │
  │                   │ ═════════════════════════════════════>│                    │
  │                   │                   │                    │                    │
  │                   │                   │   (dalej jak w planie — sekcja 14)      │
  │                   │                   │   login → ticket → connect              │
  │                   │                   │                    │ ──────────────────>│
```

### 16.3 Launch-token — jak działa

Launch-token to **jednorazowy UUID** wydawany przez API po potwierdzeniu, że launcher:
- ma aktualną wersję
- zweryfikował pliki klienta (przesyła `filesHash` obliczony z **faktycznych lokalnych plików**, nie z manifestu)

#### ⚠️ Uczciwa ocena: launch-token to speed-bump, nie kryptograficzny dowód

Endpoint `/api/launcher-token.php` jest publiczny. Atakujący, który:
1. Zna oczekiwany `filesHash` (może go obliczyć mając pliki klienta)
2. Zna `launcherVersion` (publiczna info)

…może wystawić skrypt, który pobierze token BEZ uruchamiania launchera.

**Mitygacje (warstwowe, nie pojedyncza):**
- **Warstwa 1**: Token jednorazowy + TTL 300s — ogranicza czas ataku
- **Warstwa 2**: IP-binding — token konsumowany TYLKO z tego samego IP (patrz niżej)
- **Warstwa 3**: Rate-limit na endpoint — max 5 tokenów/min z jednego IP
- **Warstwa 4**: Ticket-gate (Faza B/C) — nawet z tokenem, logowanie wymaga poprawnego email+hasło + ticket HMAC
- **Warstwa 5 (docelowo)**: Challenge-response — API wysyła losowy nonce, launcher musi zwrócić hash(nonce + zawartość losowego pliku klienta). Patrz sekcja 16.16.

> **Wniosek**: Launch-token NIE jest hard proof oficjalnego launchera (to niemożliwe przy PyInstaller). Jest jedną z WIELU warstw. Prawdziwe zabezpieczenie = ticket-gate + serwer Canary weryfikujący HMAC.

**filesHash — jak liczyć poprawnie:**
```python
def get_files_hash(manifest):
    """Hash z FAKTYCZNYCH lokalnych plików (nie z manifestu!)."""
    hashes = []
    for file_info in sorted(manifest["files"], key=lambda x: x["path"]):
        local_path = CLIENT_DIR / file_info["path"]
        if local_path.exists():
            hashes.append(sha256_file(local_path))  # hash REALNEGO pliku
        else:
            hashes.append("MISSING")
    combined = "".join(hashes)
    return hashlib.sha256(combined.encode()).hexdigest()
```

> **Dlaczego z lokalnych plików a nie z manifestu:** Gdyby filesHash liczył z haszy z manifestu serwera, to każdy mógłby podrobić ten sam hash bez posiadania prawdziwych plików. Licząc z faktycznych plików, API może porównać z oczekiwanym hashem i wykryć rozbieżność.

**TTL launch-tokena: 300 sekund (5 minut)**, nie 60s.  
Uzasadnienie: token jest pobierany PRZED startem klienta, a gracz wpisuje login dopiero po uruchomieniu. 60s to za mało na start + wpisanie danych. 300s daje bezpieczny margines.

**Klient** odbiera token przez **zmienną środowiskową** (NIE przez CLI argument!):
```python
# launcher uruchamia klienta tak:
env = os.environ.copy()
env["OTC_LAUNCH_TOKEN"] = token
subprocess.Popen([str(exe)], env=env)
```

> **Dlaczego NIE --launch-token=?** Argumenty CLI są widoczne w `ps aux`, `/proc/PID/cmdline`, logach serwera i w `application.cpp` linia 92 (`g_logger.info("Startup options: {}", startupOptions)`). Zmienna środowiskowa NIE jest logowana i nie jest widoczna w liście procesów.

Klient czyta token w `init.lua`:
```lua
local launchToken = os.getenv("OTC_LAUNCH_TOKEN") or ""
-- wysyłany w POST /login.php
```

Request do API:
```
POST /login.php
{
    "email": "...",
    "password": "...",
    "gameMode": "classic74",
    "launchToken": "uuid-jednorazowy"    ← NOWE POLE
}
```

API weryfikuje launch-token **w transakcji** (potrzebuje danych z rekordu PRZED usunięciem):
```php
function consumeLaunchToken(string $token, string $clientIp): array|false {
    $pdo->beginTransaction();
    try {
        // 1. Pobierz i zablokuj rekord (FOR UPDATE = row lock)
        $stmt = $pdo->prepare("
            SELECT files_hash, launcher_version, manifest_version, client_ip 
            FROM launch_tokens 
            WHERE token = ? AND expires_at > NOW()
            FOR UPDATE
        ");
        $stmt->execute([$token]);
        $row = $stmt->fetch();
        
        if (!$row) {
            $pdo->rollback();
            return false;  // nie istnieje / wygasły
        }
        
        // 2. Sprawdź IP (token z tego samego IP co konsumpcja)
        //
        // ⚠️ UWAGA O REVERSE PROXY / CDN:
        // Jeśli stoisz za nginx/Cloudflare, $_SERVER['REMOTE_ADDR'] = IP proxy, nie gracza!
        // Musisz użyć nagłówka X-Forwarded-For / CF-Connecting-IP,
        // ALE TYLKO po whitelistowaniu trusted proxy IP:
        //
        //   // W config.php:
        //   $TRUSTED_PROXIES = ['127.0.0.1', '172.16.0.0/12', '10.0.0.0/8'];
        //   function getRealClientIp(): string {
        //       if (in_array($_SERVER['REMOTE_ADDR'], $TRUSTED_PROXIES)
        //           && !empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        //           // Bierz OSTATNI nietrusted IP z X-Forwarded-For
        //           $chain = array_map('trim', explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']));
        //           for ($i = count($chain)-1; $i >= 0; $i--) {
        //               if (!in_array($chain[$i], $TRUSTED_PROXIES)) return $chain[$i];
        //           }
        //       }
        //       return $_SERVER['REMOTE_ADDR'];
        //   }
        //
        // Bez tego: IP-binding albo nie działa (zawsze ten sam IP proxy)
        // albo jest spoofable (atakujący ustawia swój X-Forwarded-For).
        //
        if ($row['client_ip'] !== $clientIp) {
            $pdo->rollback();
            return false;  // kradziony token
        }
        
        // 3. Atomowo usuń (konsumuj)
        $pdo->prepare("DELETE FROM launch_tokens WHERE token = ?")->execute([$token]);
        $pdo->commit();
        
        return $row;  // zwróć dane do dalszej walidacji
    } catch (Exception $e) {
        $pdo->rollback();
        return false;
    }
}

// W login.php:
$tokenData = consumeLaunchToken($launchToken, $_SERVER['REMOTE_ADDR']);
if (!$tokenData) {
    die(json_encode(["error" => "Uruchom grę przez launcher"]));
}
// Sprawdź filesHash DLA WERSJI Z TOKENA (nie obligatoryjnie latest!):
$acceptedVersions = getAcceptedManifestVersions(); // [current, previous]
if (!in_array($tokenData['manifest_version'], $acceptedVersions)) {
    die(json_encode(["error" => "Wersja klienta nieaktualna, zrestartuj launcher"]));
}
$expectedHash = computeExpectedFilesHash(
    getManifest($channel, $tokenData['manifest_version'])
);
if ($tokenData['files_hash'] !== $expectedHash) {
    die(json_encode(["error" => "Pliki klienta nieaktualne"]));
}
// Dalej: normalna weryfikacja email+hasło...
```

> **Dlaczego nie proste DELETE + affected_rows?** Bo DELETE kasuje rekord — tracimy `files_hash` i `client_ip` potrzebne do walidacji. SELECT FOR UPDATE + DELETE w transakcji = atomowe (row lock blokuje inne połączenia) + mamy dane.

**Bez launch-tokena = nie zaloguj się.** To zamyka lukę "ktoś odpala klienta bezpośrednio".

### 16.4 Technologia launchera

**Rekomendacja: Python + PyInstaller** (najszybszy development)

| Opcja | Plusy | Minusy | Czas |
|-------|-------|--------|------|
| **Python + PyInstaller** | Szybki dev, requests/hashlib wbudowane, tkinter GUI | .exe ~30MB, łatwy do dekompilacji | ~15h |
| C# WinForms | Natywny Windows, mały .exe ~5MB | Wymaga .NET runtime | ~20h |
| Electron | Ładny UI, cross-platform | Ogromny .exe ~120MB | ~25h |
| C++ (Qt/wxWidgets) | Mały, trudny do RE | Długi development | ~40h |
| Tauri (Rust + webview) | Mały ~5MB, ładny UI, trudny do RE | Rust learning curve | ~30h |

**Decyzja:** Python + PyInstaller na start, docelowo można przepisać na Tauri.

### 16.4.1 Referencje — oficjalne repo OTC

Poniżej linki referencyjne do ekosystemu OTClient (upstream + OTCv8), użyte przy analizie launchera:

- Upstream OTClient (edubart): https://github.com/edubart/otclient
- OTCv8 klient (fork z własnym rozwojem): https://github.com/OTCv8/otclientv8
- OTCv8 tools (m.in. updater/api tooling): https://github.com/OTCv8/otcv8-tools

> Uwaga: w upstream `edubart/otclient` nie ma osobnego, oficjalnego repo standalone launchera.
> Dlatego `build_launcher.sh`/`launcher.py` w tym projekcie to warstwa własna (projektowa), a nie element bazowego upstreamu.

### 16.5 Struktura plików launchera

```
InstallDir/
├── launcher.exe                 ← Gracz to uruchamia
├── launcher_config.json         ← URL API, kanał aktualizacji
├── client/
│   ├── otclient.exe             ← Klient gry (aktualizowany przez launcher)
│   ├── init.lua
│   ├── data/
│   │   ├── things/
│   │   ├── sprites/
│   │   └── ...
│   ├── modules/
│   │   ├── client_entergame/
│   │   ├── client_serverlist/
│   │   └── ...
│   └── ...
└── cache/
    ├── manifest.json            ← Ostatni pobrany manifest
    └── downloads/               ← Tymczasowe pliki podczas pobierania
```

### 16.6 launcher_config.json

```json
{
    "apiBaseUrl": "https://twoja-domena.pl/api",
    "filesBaseUrl": "https://twoja-domena.pl",
    "updateChannel": "stable",
    "clientDir": "./client",
    "clientExe": "otclient.exe",
    "launcherVersion": "1.0.0",
    "minLauncherVersion": "1.0.0"
}
```

> **UWAGA o URL-ach**: `apiBaseUrl` = endpointy PHP (`/api/update.php`), `filesBaseUrl` = root domeny do pobierania plików (`/files/...`). Oddzielenie zapobiega błędowi `/api/files/...`.

### 16.7 API endpoints (serwer WWW)

| Endpoint | Metoda | Opis | Odpowiedź |
|----------|--------|------|-----------|
| `/api/launcher-version.php` | GET | Aktualna wersja launchera | `{"version": "1.0.0", "url": "...", "required": false}` |
| `/api/update.php?channel=stable` | GET | Manifest plików klienta | `{"version": "1.4.2", "files": [...]}` |
| `/api/launcher-token.php` | POST | Wydaj launch-token | `{"launchToken": "uuid", "expiresIn": 300}` |
| `/files/{path}` | GET | Pobierz plik klienta | Plik binarny |

### 16.8 Pseudokod launchera (Python)

```python
import hashlib, json, os, subprocess, sys, requests, uuid
from pathlib import Path

CONFIG = json.load(open("launcher_config.json"))
API = CONFIG["apiBaseUrl"]          # https://domena.pl/api  (do endpointów API)
FILES_BASE_URL = CONFIG["filesBaseUrl"]  # https://domena.pl  (do pobierania plików z /files/...)
CLIENT_DIR = Path(CONFIG["clientDir"])

def check_launcher_update():
    """Sprawdź czy jest nowsza wersja launchera."""
    resp = requests.get(f"{API}/launcher-version.php", timeout=10).json()
    if resp["version"] != CONFIG["launcherVersion"]:
        if resp.get("required"):
            download_and_replace_launcher(resp["url"])
            sys.exit(0)  # restart po update
        else:
            show_optional_update_banner(resp["version"])

def get_manifest():
    """Pobierz manifest plików z serwera."""
    resp = requests.get(f"{API}/update.php", 
                        params={"channel": CONFIG["updateChannel"]}, 
                        timeout=30)
    return resp.json()

def sha256_file(path):
    """Oblicz SHA256 lokalnego pliku."""
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def check_and_update(manifest):
    """Porównaj lokalne pliki z manifestem, pobierz brakujące/zmienione, usuń nadmiarowe.
    
    STRATEGIA BEZPIECZNA (crash-safe):
    1. Najpierw POBIERZ wszystkie nowe/zmienione pliki do cache/downloads/ (temp)
    2. Zweryfikuj hashe POBRANYCH plików
    3. Dopiero potem: atomic rename temp → docelowy (nadpisanie)
    4. Na KOŃCU: skasuj pliki nadmiarowe
    
    Jeśli sieć padnie w kroku 1/2 — stary klient nadal działa.
    """
    manifest_paths = {f["path"] for f in manifest["files"]}
    to_download = []
    
    # Sprawdź pliki z manifestu — nowe lub zmienione
    for file_info in manifest["files"]:
        # ⚠️ PATH TRAVERSAL PROTECTION:
        # Manifest przychodzi z serwera — mogłby zawierać złośliwe ścieżki!
        safe_path = validate_manifest_path(file_info["path"])
        if safe_path is None:
            raise Exception(f"Niebezpieczna ścieżka w manifeście: {file_info['path']}")
        
        local_path = CLIENT_DIR / safe_path
        if not local_path.exists():
            to_download.append(file_info)
        elif sha256_file(local_path) != file_info["sha256"]:
            to_download.append(file_info)  # zmieniony lub zmodyfikowany
    
    if not to_download:
        # Nadal sprawdzamy nadmiarowe pliki
        pass
    else:
        # KROK 1: Pobierz WSZYSTKO do temp (cache/downloads/)
        temp_dir = Path("cache/downloads")
        temp_dir.mkdir(parents=True, exist_ok=True)
        
        for i, file_info in enumerate(to_download):
            update_progress(i + 1, len(to_download), file_info["path"])
            download_file_to_temp(file_info, temp_dir)  # pobiera do temp
        
        # KROK 2: Atomic rename temp → docelowy
        for file_info in to_download:
            safe_path = validate_manifest_path(file_info["path"])
            temp_path = temp_dir / safe_path
            final_path = CLIENT_DIR / safe_path
            final_path.parent.mkdir(parents=True, exist_ok=True)
            # os.replace() jest atomowy na tym samym filesystem
            os.replace(str(temp_path), str(final_path))
    
    # KROK 3: Usuń pliki nadmiarowe DOPIERO PO udanym pobraniu
    to_delete = []
    for local_file in CLIENT_DIR.rglob("*"):
        if local_file.is_file():
            rel_path = str(local_file.relative_to(CLIENT_DIR)).replace("\\", "/")
            if rel_path not in manifest_paths:
                to_delete.append(local_file)
    
    for old_file in to_delete:
        old_file.unlink()
        update_status(f"Usunięto stary plik: {old_file.name}")
    
    # Cleanup temp
    if (temp_dir := Path("cache/downloads")).exists():
        import shutil
        shutil.rmtree(temp_dir, ignore_errors=True)
    
    update_status(f"Zaktualizowano {len(to_download)} plików, usunięto {len(to_delete)} starych.")

def validate_manifest_path(path: str) -> str | None:
    """Walidacja ścieżki z manifestu — ochrona przed path traversal.
    
    Odrzuca:
    - ścieżki z '..' (wyjście poza CLIENT_DIR)
    - ścieżki absolutne (/etc/passwd, C:\\...)
    - ścieżki z null byte
    - symlinki (resolve musi kończyć się w CLIENT_DIR)
    """
    # Null byte
    if '\x00' in path:
        return None
    
    # Normalizuj i sprawdź components
    normalized = os.path.normpath(path)
    
    # Absolutna ścieżka
    if os.path.isabs(normalized):
        return None
    
    # Parent traversal (.. po normalizacji)
    if normalized.startswith('..'):
        return None
    
    # Sprawdź czy resolved path jest w CLIENT_DIR
    resolved = (CLIENT_DIR / normalized).resolve()
    if not str(resolved).startswith(str(CLIENT_DIR.resolve())):
        return None
    
    return normalized

def download_file_to_temp(file_info, temp_dir, max_retries=3):
    """Pobierz plik do katalogu TYMCZASOWEGO i zweryfikuj hash.
    
    WAŻNE o URL-ach:
    - API endpoints: {apiBaseUrl}/update.php  (np. https://domena.pl/api/update.php)
    - Pliki klienta: file_info["url"] zaczyna się od "/files/..." (bezwzględna ścieżka)
    - Używamy FILES_BASE_URL (bez /api) do pobierania plików!
    """
    temp_path = temp_dir / validate_manifest_path(file_info["path"])
    temp_path.parent.mkdir(parents=True, exist_ok=True)
    
    # URL: base domain + url z manifestu (NIE apiBaseUrl!)
    # apiBaseUrl = "https://domena.pl/api" → FILES_BASE = "https://domena.pl"
    download_url = f"{FILES_BASE_URL}{file_info['url']}"  # /files/stable/1.4.2/otclient.exe
    
    for attempt in range(max_retries):
        resp = requests.get(download_url, stream=True, timeout=60)
        resp.raise_for_status()
        with open(temp_path, "wb") as f:
            for chunk in resp.iter_content(8192):
                f.write(chunk)
        
        if sha256_file(temp_path) == file_info["sha256"]:
            return  # OK — plik w TEMP, jeszcze NIE w docelowym miejscu
        # Hash nie pasuje — retry
    
    raise Exception(f"Nie udało się pobrać {file_info['path']} po {max_retries} próbach")

def get_files_hash(manifest):
    """Hash z FAKTYCZNYCH LOKALNYCH plików (nie z manifestu serwera!)."""
    hashes = []
    for file_info in sorted(manifest["files"], key=lambda x: x["path"]):
        local_path = CLIENT_DIR / file_info["path"]
        if local_path.exists():
            hashes.append(sha256_file(local_path))  # hash REALNEGO pliku
        else:
            hashes.append("MISSING")
    combined = "".join(hashes)
    return hashlib.sha256(combined.encode()).hexdigest()

def get_launch_token(manifest):
    """Pobierz jednorazowy token startowy z API.
    
    WAŻNE: Wysyłamy też manifest["version"] — API wiąże token z KONKRETNĄ
    wersją manifestu. Jeśli w MO międzyczasie nastąpi rollout nowej wersji,
    token pozostaje ważny dla STAREJ wersji (grace period).
    """
    resp = requests.post(f"{API}/launcher-token.php", json={
        "launcherVersion": CONFIG["launcherVersion"],
        "filesHash": get_files_hash(manifest),
        "clientVersion": manifest["version"],
        "manifestVersion": manifest["version"],  # API zapisuje w tokenie
    }, timeout=10)
    data = resp.json()
    if "error" in data:
        raise Exception(data["error"])
    return data["launchToken"]

def launch_client(token):
    """Uruchom klienta z tokenem przez zmienną środowiskową.
    
    WAŻNE: NIE przekazujemy tokena przez --launch-token=!
    Argumenty CLI są widoczne w 'ps aux', /proc/PID/cmdline i logowane
    przez application.cpp:92 (g_logger.info("Startup options: ...")).
    Zmienna środowiskowa jest bezpieczniejsza.
    """
    exe = CLIENT_DIR / CONFIG["clientExe"]
    env = os.environ.copy()
    env["OTC_LAUNCH_TOKEN"] = token   # ← przez env, NIE CLI
    subprocess.Popen([str(exe)], env=env)

def main():
    try:
        update_status("Sprawdzanie aktualizacji launchera...")
        check_launcher_update()
        
        update_status("Pobieranie listy plików...")
        manifest = get_manifest()
        
        update_status("Sprawdzanie plików klienta...")
        check_and_update(manifest)
        
        update_status("Przygotowanie do uruchomienia...")
        token = get_launch_token(manifest)
        
        update_status("Uruchamianie gry...")
        launch_client(token)
        
    except Exception as e:
        show_error(str(e))
```

### 16.9 GUI launchera

```
┌──────────────────────────────────────────┐
│          🛡️  NAZWA TWOJEGO SERWERA       │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │                                    │  │
│  │         [GRAFIKA/LOGO]             │  │
│  │                                    │  │
│  └────────────────────────────────────┘  │
│                                          │
│  Wersja klienta: 1.4.2                  │
│  Status: Klient aktualny                 │
│                                          │
│  ████████████████████████░░ 85%          │
│  Pobieranie: data/tibia.dat (12/15 MB)   │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │           [  GRAJ  ]              │  │
│  └────────────────────────────────────┘  │
│                                          │
│  Aktualności:                            │
│  • 01.03 — Nowy event Double Exp!        │
│  • 28.02 — Poprawki UI i tłumaczenia     │
│                                          │
│  [Ustawienia]  [Discord]  [Strona WWW]   │
└──────────────────────────────────────────┘
```

### 16.10 Manifest plików — struktura

Endpoint `/api/update.php` zwraca:

```json
{
    "version": "1.4.2",
    "releaseDate": "2026-03-01",
    "channel": "stable",
    "files": [
        {
            "path": "otclient.exe",
            "sha256": "a1b2c3d4e5f6...",
            "size": 15728640,
            "url": "/files/stable/1.4.2/otclient.exe"
        },
        {
            "path": "init.lua",
            "sha256": "f6e5d4c3b2a1...",
            "size": 4096,
            "url": "/files/stable/1.4.2/init.lua"
        },
        {
            "path": "modules/client_entergame/entergame.lua",
            "sha256": "112233445566...",
            "size": 32768,
            "url": "/files/stable/1.4.2/modules/client_entergame/entergame.lua"
        }
    ],
    "changelog": [
        {"date": "2026-03-01", "text": "Launcher + auto-update"},
        {"date": "2026-02-28", "text": "Poprawki UI w opcjach"}
    ]
}
```

### 16.11 Generowanie manifestu (skrypt serwerowy)

```php
<?php
// generate_manifest.php — uruchamiany po każdym uupdacie plików klienta
// Użycie: php generate_manifest.php /var/www/files/stable/1.4.2/ > manifest.json

$dir = $argv[1];
$baseUrl = "/files/stable/1.4.2";
$files = [];

$iterator = new RecursiveIteratorIterator(
    new RecursiveDirectoryIterator($dir, FilesystemIterator::SKIP_DOTS)
);

foreach ($iterator as $file) {
    if ($file->isFile()) {
        $relativePath = str_replace($dir . '/', '', $file->getPathname());
        $files[] = [
            'path' => $relativePath,
            'sha256' => hash_file('sha256', $file->getPathname()),
            'size' => $file->getSize(),
            'url' => $baseUrl . '/' . $relativePath,
        ];
    }
}

echo json_encode([
    'version' => '1.4.2',
    'releaseDate' => date('Y-m-d'),
    'channel' => 'stable',
    'files' => $files,
], JSON_PRETTY_PRINT);
```

### 16.12 Tabela launch_tokens (MySQL)

```sql
CREATE TABLE launch_tokens (
    token VARCHAR(64) PRIMARY KEY,
    launcher_version VARCHAR(20) NOT NULL,
    files_hash VARCHAR(64) NOT NULL,
    manifest_version VARCHAR(20) NOT NULL,   -- wersja manifestu przy wydaniu tokena
    client_ip VARCHAR(45) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB;

-- Konsumpcja (SELECT FOR UPDATE + DELETE w transakcji):
-- BEGIN;
-- SELECT files_hash, manifest_version, client_ip
--   FROM launch_tokens WHERE token = ? AND expires_at > NOW() FOR UPDATE;
-- (weryfikuj client_ip == IP żądającego)
-- (weryfikuj files_hash == oczekiwany hash DLA TEJ manifest_version, nie obligatoryjnie latest!)
-- DELETE FROM launch_tokens WHERE token = ?;
-- COMMIT;
--
-- FOR UPDATE = row lock → inne połączenia czekają (atomowe)
-- Mamy dane z rekordu PRZED usunięciem → możemy porównać filesHash i IP
--
-- Cleanup cron (co 15 min):
-- DELETE FROM launch_tokens WHERE expires_at < NOW();
```

> **UWAGA**: Tabela NIE ma kolumny `used_at`. Token jest **usuwany** przy konsumpcji. Używamy transakcji (SELECT FOR UPDATE + DELETE) zamiast prostego DELETE, bo potrzebujemy danych z rekordu (files_hash, manifest_version, client_ip) do walidacji.

> **IP binding**: Token zapisany z IP launchera (`client_ip`) jest porównywany z IP klienta przy logowaniu. Jeśli launcher i klient są na tym samym komputerze (=ten sam NAT/IP), to działa. Chroni przed scenariuszem: atakujący generuje token ze skryptu na swoim IP, a próbuje użyć go z innego IP.
>
> **⚠️ O reverse proxy / CDN (Cloudflare, nginx)**: Jeśli API stoi za proxy, musisz użyć `getRealClientIp()` z sekcji 16.3 (whitelisted trusted proxies + X-Forwarded-For parsing). Bez tego `client_ip` będzie zawsze IP proxy i IP-binding nie działa.

> **Wersjonowanie manifestu (race condition przy rollout)**:  
> Przy wdrażaniu nowej wersji między wydaniem tokena a loginem, legalny gracz mógłby zostać odrzucony (jego `filesHash` pasuje do starej wersji). Rozwiązanie:  
> - Token zawiera `manifest_version` z momentu wydania  
> - API przy konsumpcji porównuje `filesHash` z hashem DLA TEJ wersji (nie obligatoryjnie latest)  
> - API akceptuje current + previous wersję (grace period 10 min po rollout)  
> - Po grace period: tylko current jest akceptowany  
> ```php
> // W launcher-token.php przy wydawaniu:
> $manifest = getManifest($channel); // current version
> $expectedHash = computeExpectedFilesHash($manifest);
> // ... INSERT z manifest_version = $manifest['version']
> 
> // W login.php przy konsumpcji:
> $tokenData = consumeLaunchToken($token, getRealClientIp());
> $acceptedVersions = getAcceptedManifestVersions(); // [current, previous]
> if (!in_array($tokenData['manifest_version'], $acceptedVersions)) {
>     die(json_encode(['error' => 'Wersja klienta nieaktualna, zrestartuj launcher']));
> }
> $expectedHash = computeExpectedFilesHash(getManifest($channel, $tokenData['manifest_version']));
> if ($tokenData['files_hash'] !== $expectedHash) { reject; }
> ```

### 16.13 Ochrona launchera przed obejściem

| Atak | Mitygacja |
|------|-----------|
| Uruchomienie klienta bez launchera | Klient wymaga `OTC_LAUNCH_TOKEN` (env), API wymaga launch-token przy loginie |
| Podrobienie launch-tokena | Token UUID generowany przez API, jednorazowy, TTL 300s, atomowe DELETE |
| Modyfikacja launchera (dekompilacja Python) | filesHash liczony z REALNYCH lokalnych plików — API porównuje z oczekiwanym hashem z manifestu |
| MITM na update download | Pliki weryfikowane po pobraniu (sha256 z manifestu), manifest po HTTPS |
| Podmiana manifestu | Manifest pobierany po HTTPS z certificate verification + **opcjonalny HMAC** (patrz 16.14) |
| Downgrade (stare pliki) | API wie jaka jest najnowsza wersja, `filesHash` musi pasować |

> **Uwaga**: Launcher Python+PyInstaller jest łatwy do dekompilacji. Dla MVP to wystarczy (bo i tak ticket-gate chroni serwer). Docelowo przepisać na kompilowany język (Rust/C++).

### 16.14 Opcjonalny podpis HMAC manifestu

Dla dodatkowej warstwy ochrony (poza HTTPS), manifest może zawierać podpis:

```json
{
    "version": "1.4.2",
    "files": [...],
    "signature": "hmac-sha256-hex-tutaj"
}
```

**Generowanie (serwer):**
```php
$manifest = json_encode($data, JSON_PRETTY_PRINT);
$signature = hash_hmac('sha256', $manifest, $MANIFEST_SECRET_KEY);
// Dodaj signature do response
```

**Weryfikacja (launcher):**
```python
def verify_manifest_signature(manifest_json: str, signature: str) -> bool:
    expected = hmac.new(MANIFEST_KEY.encode(), manifest_json.encode(), hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, signature)
```

> **Priorytet**: NISKI — HTTPS z certificate verification to główna ochrona. HMAC to defense-in-depth. Klucz osadzony w launcherze można wyekstrahować z PyInstaller, więc to bardziej "speed bump" niż realny mur.

### 16.16 Challenge-response (docelowe wzmocnienie launch-tokena)

> **Priorytet**: NISKI/OPCJONALNY — implementować jeśli atakujący aktywnie obchodzą launcher.

Standardowy launch-token opiera się na `filesHash` dostarczonym przez klienta. Atakujący, który ma pliki klienta, może obliczyć hash i zdosprawić ten sam request BEZ launchera.

**Challenge-response utrudnia to:**

```
LAUNCHER                          API
  │                                 │
  │ 1. GET /challenge.php            │
  │ ────────────────────────────────>│
  │                                 │
  │ 2. {challengeId, nonce,          │
  │     filePath: "modules/xyz.lua"} │
  │ <────────────────────────────────│
  │                                 │
  │ 3. Launcher czyta FAKTYCZNY      │
  │    plik z dysku:                 │
  │    content = read(filePath)      │
  │    response = sha256(nonce +     │
  │               content)           │
  │                                 │
  │ 4. POST /launcher-token.php      │
  │    {challengeId, response,       │
  │     launcherVersion, filesHash}  │
  │ ────────────────────────────────>│
  │                                 │
  │ 5. API sprawdza:                 │
  │    expected = sha256(nonce +     │
  │               serverContent)     │
  │    if response != expected       │
  │      → REJECT                    │
  │    else → wydaj launchToken       │
```

**Dlaczego to pomaga:**
- Nonce jest losowy i jednorazowy → nie da się pre-compute
- `filePath` jest losowy (API wybiera spośród ~100 plików) → atakujący musiałby mieć WSZYSTKIE pliki
- Nawet jeśli atakujący ma pliki, musi nieś prawidłową odpowiedź w <5s (TTL challenge)

**Dlaczego to NIE jest niezawodne:**
- Atakujący z pełną kopią plików (np. po normalnej instalacji) może odpowiadać
- PyInstaller da się zdekompilować → logika jest jawna
- Jest to "raise the bar" a nie "impossible to break"

**Implementacja: Faza E bonus (+3h)**

### 16.15 Hard-fail TLS

Launcher MUSI wymuszać TLS i NIGDY nie fallback'ować na HTTP:

```python
# POPRAWNE — hard-fail TLS
resp = requests.get("https://...", verify=True, timeout=10)
# Jeśli cert invalid → requests.SSLError → show_error() → STOP

# ZABRONIONE — NIE ROBIĆ:
# requests.get("http://...")      ← plaintext
# verify=False                    ← wyłączone
# except SSLError: try http://    ← fallback
```

> To samo dotyczy klienta C++ (`httplogin.cpp`) — zadanie X2 w sekcji 15 wymaga naprawienia `enable_server_certificate_verification(false)` i usunięcia HTTP fallback.

---

## 17. Faza E — Plan implementacji launchera ✅ (12/13)

| # | Zadanie | Trudność | Czas | Status |
|---|---------|----------|------|--------|
| E1 | Skrypt `generate_manifest.php` | ŁATWE | 1h | ✅ DONE |
| E2 | Endpoint `GET /api/update.php` | ŁATWE | 1h | ✅ DONE |
| E3 | Endpoint `POST /api/launcher-token.php` | ŚREDNIE | 2h | ✅ DONE |
| E4 | Endpoint `GET /api/launcher-version.php` | ŁATWE | 30min | ✅ DONE |
| E5 | Tabela `launch_tokens` w MySQL + cleanup cron | ŁATWE | 30min | ✅ DONE |
| E6 | Launcher Python: sprawdzanie plików + pobieranie | ŚREDNIE | 4h | ✅ DONE |
| E7 | Launcher Python: GUI (tkinter) + pasek postępu | ŚREDNIE | 3h | ✅ DONE |
| E8 | Launcher Python: launch-token + uruchomienie klienta | ŁATWE | 1h | ✅ DONE |
| E9 | Launcher: self-update | ŚREDNIE | 2h | ✅ DONE |
| E10 | Klient: obsługa `OTC_LAUNCH_TOKEN` env variable + C++ + Lua | ŁATWE | 1h | ✅ DONE |
| E11 | API `login.php`: walidacja `launchToken` przy loginie | ŚREDNIE | 2h | ✅ DONE |
| E12 | Smoke test: launch-token flow (CLI) | ŁATWE | 1h | ✅ DONE |
| E13 | Hosting plików klienta na serwerze WWW | ŁATWE | 1h | ⬜ TODO |
| **PYINST** | **Build launchera PyInstaller** (.exe/.linux) | ŚREDNIE | 2h | ⬜ TODO |
| **CFG** | **Naprawa `launcher_config.json`** — klucze niezgodne z `launcher.py` | ŁATWE | 15min | 🔴 BLOKER (patrz audyt #14) |
| | **Suma Fazy E** | | **~22h** | **12/15 ✅ + 2 ⬜ + 1 🔴** |

---

## 18. Finalna architektura (wszystkie warstwy)

```
                                ┌──────────────────────┐
                                │    TWÓJ SERWER WWW   │
                                │    (Apache/nginx)    │
                                │                      │
  ┌─────────────┐   HTTPS       │  /api/update.php     │   ┌──────────────┐
  │  LAUNCHER   │ ─────────────>│  /api/launcher-token  │   │   MySQL DB   │
  │  (.exe)     │ <─────────────│  /api/launcher-ver    │   │  accounts    │
  │             │   manifest    │  /files/...           │   │  players     │
  │  1.Sprawdź  │   + token     │                      │   │  launch_tok  │
  │  2.Pobierz  │               │  /login.php    ──────┼──>│  ticket_non  │
  │  3.Uruchom  │               │  /ticket.php         │   │  sessions    │
  └──────┬──────┘               │                      │   └──────────────┘
         │ env: OTC_LAUNCH_TOKEN └──────────┬───────────┘
         ▼                                 │
  ┌─────────────┐   HTTPS                  │
  │  KLIENT GRY │ ─────────────────────────┘
  │  (OTClient) │       login + ticket
  │             │
  │  4.Login    │   ticket (HMAC)     ┌──────────────┐
  │  5.Postać   │ ───────────────────>│  CANARY      │
  │  6.Ticket   │                     │  (game srv)  │
  │  7.Connect  │ ═══════════════════>│  port 7172   │
  └─────────────┘   game protocol     └──────────────┘
```

---

## 19. Łączna estymacja — wszystkie fazy

| Faza | Opis | Czas | canary/ | canary_test/ |
|------|------|------|---------|-------------|
| A | Klient UX: tryby, blokada serwerów | ~10h | ✅ 6/8 | ✅ 6/8 |
| B | API HTTP: ticket-gate 2-fazowy | ~14h | ✅ 7/7 | ✅ 7/7 |
| C | Serwer Canary: weryfikacja ticketu | ~13h | ✅ 6/6 | ✅ 6/6 (guardy naprawione `dfe1a8784`) |
| D | Feature flags serwer — blokady Classic 7.4 | ~14h | ✅ 11/11 | ✅ 11/11 (guardy D2-D7 naprawione) |
| Audyt (X1-X8) | Korekty po review kodu | ~18h | ✅ 8/8 | ✅ 8/8 (X8 OpenSSL done) |
| FIX1-FIX65 | Poprawki z 7-audytów Codex/ChatGPT | ~15h | ✅ 65 fixów | ✅ 65 fixów |
| **E** | **Launcher z auto-update** | **~22h** | ✅ 12/15 | ✅ LNCFG done (FIX-AUD14) |
| **Port** | **Port C++ z canary/ do canary_test/** | **~3h** | — | ✅ guardy naprawione |
| | **ŁĄCZNIE** | **~109h** | **~98%** | **~95%** |

### ⬜ CO JESZCZE BRAKUJE (lista otwartych zadań)

#### Priorytet 1 — 🔴 KRYTYCZNE (blokery kompilacji / uruchomienia)
| # | Zadanie | Opis | Szacowany czas | Status |
|---|---------|------|----------------|--------|
| **GUARD-FIX** | **Naprawa guardów D2-D7 w canary_test/** | Skopiować poprawne guardy z canary/ do canary_test/protocolgame.cpp (11 lokalizacji) | 2-3h | ✅ DONE (dfe1a8784) |
| X8 | Explicit OpenSSL w vcpkg.json + CMake | `#include <openssl/hmac.h>` wymaga OpenSSL::Crypto — dodać do vcpkg.json i target_link_libraries | 30min | ✅ DONE (dfe1a8784) |
| **CFG-KEY** | **Brakujące 3 klucze config** | ticketMaxAge, ticketClockTolerance, worldId — config_enums.hpp + configmanager.cpp + config.lua.dist | 30min | ✅ DONE (dfe1a8784) |
| **LNCFG** | **Naprawić launcher_config.json** | Klucze apiUrl→apiBaseUrl, clientFolder→clientDir, clientExecutable→clientExe (match launcher.py) | 15min | ✅ DONE (FIX-AUD14) |
| A8 | Kompilacja klienta OTClient | Push → GHA workflow → weryfikacja kompilacji Windows + Linux | 2-4h | ⏳ CZEKA na GUARD-FIX |
| C6 | Kompilacja serwera Canary | GHA workflow → weryfikacja kompilacji C++ (ticket_validator, protocolgame) | 2-4h | ⏳ CZEKA na GUARD-FIX + X8 |
| **DB** | **Schema SQL na produkcji** | Tabele `ticket_nonces`, `ticket_sessions`, `launch_tokens`, `manifest_versions` | 30min | ⬜ TODO |

#### Priorytet 2 — WYSOKIE (wymagane do pełnej funkcjonalności)
| # | Zadanie | Opis | Szacowany czas |
|---|---------|------|----------------|
| D11 | Test integracyjny feature flags | Zalogowanie jako Classic 7.4 → weryfikacja każdej blokady (Market, Prey, Wheel, Bestiary, QuickLoot, SmartEquip, rune hotkey, rate-limit ruchu) | 4h |
| E13 | Hosting plików klienta | CDN/serwer HTTP do pobierania plików przez launcher (/files/stable/...) | 2h |
| **PYINST** | **Build launchera PyInstaller** | `launcher.py` → `launcher.exe` (Windows) i `launcher` (Linux) via PyInstaller | 2h |
| **DEPLOY** | **.env produkcyjny** | Konfiguracja TICKET_SECRET, WORLD_IP, CLIENT_LOCKED na serwerze produkcyjnym | 1h |

#### Priorytet 3 — ŚREDNIE (ulepszenia, hardening)
| # | Zadanie | Opis | Szacowany czas |
|---|---------|------|----------------|
| FIX36 | IP-binding za NAT/proxy | Trusted proxy headers (X-Forwarded-For) — wymaga konfiguracji nginx | 2h |
| FIX37 | Fresh install docs | Dokumentacja setup od zera: schema SQL, .env, nginx, certyfikaty | 3h |
| FIX40 | Cron cleanup sesji | Zastąpienie probabilistycznego cleanup (10%) cronem | 1h |
| FIX41 | apiPort/gamePort separation | Oddzielenie portów API (443) i game (7172) w konfiguracji klienta | 2h |
| **CERT** | **Certyfikat Let's Encrypt** | Zastąpienie self-signed cert prawdziwym certyfikatem na produkcji | 2h |
| **METRICS** | **Logi/metryki odrzuceń ticket** | Structured logging w Canary: REJECT reason, IP, account, latency (sekcja 11.8) | 4h |

#### Priorytet 4 — NISKIE (opcjonalne, defense-in-depth)
| # | Zadanie | Opis | Szacowany czas |
|---|---------|------|----------------|
| **PINNING** | Certificate pinning w kliencie | Hardcode SPKI hash w httplogin.cpp — ochrona przed MITM z fałszywym certem | 4h |
| **CHALLENGE** | Challenge-response launcher | Sekcja 16.16 — losowy nonce + hash pliku → utrudnia obejście launchera | 3h |
| **TAURI** | Przepisanie launchera na Tauri/Rust | Trudniejszy do dekompilacji niż Python+PyInstaller | 40h |
| **ROTACJA** | Rotacja kluczy HMAC (`kid`) | Multi-key support w ticket_validator + ticket.php (sekcja 11.2) | 4h |

### Rekomendowana kolejność (zaktualizowana 2026-03-03):
1. ~~**Faza A** (klient UX)~~ — ✅ ZROBIONE
2. ~~**Fazy B+C+D** (API + serwer)~~ — ✅ ZROBIONE
3. ~~**Faza E** (launcher)~~ — ✅ ZROBIONE
4. ~~**Port do canary_test/**~~ — ✅ ZROBIONE (`98964825b`)
5. ~~**FIX1-FIX65** (65 audytowych poprawek)~~ — ✅ ZROBIONE
6. ~~**GUARD-FIX + X8 + CFG-KEY + LNCFG**~~ — ✅ ZROBIONE (`dfe1a8784`, `6584a0187`)
7. **🔴 TERAZ**: GHA kompilacja (A8+C6) → schema SQL (DB) → E13 hosting
8. **POTEM**: PyInstaller build + .env produkcja
9. **DOCELOWO**: Let's Encrypt, cert pinning, metrics, challenge-response

> **Dlaczego B przed E?** Launcher bez ticket-gate = pozorne bezpieczeństwo. Każdy może wystawić skrypt wysyłający POST /login.php bez launch-tokena (jeśli API go nie wymaga) lub z ukradzionym tokenem. Ticket-gate (Faza B/C) to PRAWDZIWA bariera — HMAC podpisany serwerowym kluczem, którego nie da się sfałszować. Launcher (Faza E) to warstwa UX + dodatkowy speed-bump, ale nie zastępuje kryptografii.

---

*Dokument utworzony: 2026-03-01*  
*Zaktualizowany: 2026-03-01 (sekcja 11 — wymagania bezpieczeństwa produkcyjnego)*  
*Zaktualizowany: 2026-03-01 (sekcja 13-15 — audyt kodu, weryfikacja Codex)*  
*Zaktualizowany: 2026-03-01 (sekcja 16-19 — Faza E: launcher z auto-update)*  
*Zaktualizowany: 2026-03-01 (przegląd 3 — usunięcie sprzeczności: 2-fazowy flow, atomowe nonce/token, filesHash z lokalnych plików, TTL 300s, ticket.php walidacje, manifest HMAC, hard-fail TLS)*  
*Zaktualizowany: 2026-03-01 (przegląd 4 — launch-token: uczciwa ocena bezpieczeństwa, token przez env nie CLI, IP-binding, SELECT FOR UPDATE+DELETE, bezpieczna strategia update z temp+rename, fix URL, challenge-response, kolejność: B przed E)*  
*Zaktualizowany: 2026-03-01 (przegląd 5 — cel biznesowy vs architektura: hierarchia warstw, reverse proxy/CDN IP policy, manifest version pinning przy rollout, ujednolicenie TTL ticket=30s, path traversal protection, usunięcie starego 1-fazowego wpisu)*
*Zaktualizowany: 2026-03-01 (sekcja 5.3 rozszerzona — twarde blokady server-side Classic 7.4 w Canary C++: GameMode enum, guard w parseUseWithCreature/parseQuickLoot/parseMarket*/parsePrey*/parseWheel*, rate-limit run 1000ms, tabela pewności klient vs serwer, Faza D rozszerzona D1-D11 ~14h)*  
*Zaktualizowany: 2026-03-01 (POSTĘP IMPLEMENTACJI — Fazy A+C+D ✅, B ✅, audyt X1-X8 ✅, E ✅ GOTOWE)*  
*Zaktualizowany: 2026-03-01 (CODEX FIX1-FIX8 — 8 bugów naprawionych: guardy protocolgame, CMake, authType, worldName, HMAC docs, fail-closed, D8 docs, ServerList read-only)*  
*Zaktualizowany: 2026-03-02 (sekcja 16.4.1 — dodane linki referencyjne do oficjalnych repo OTC: edubart/otclient, OTCv8/otclientv8, OTCv8/otcv8-tools)*  
*Zaktualizowany: 2026-03-02 (FIX9-FIX17 — 8 bugów z 2. audytu Codex: Wheel D6 guards, auth-after-ticket bypass, manifest bypass, worldName binding, ServerList empty, CLIENT_LOCKED drift, icon.ico)*  
*Źródło: zarys_planu_modyfikacji_klienta.md + analiza kodu + review ChatGPT ×3 + review Codex ×5 + 2× Codex FIX session*  
*Zaktualizowany: 2026-03-03 (port C++ canary/ → canary_test/, commit `98964825b`, sekcja 19 rozszerzona o "Co brakuje", ścieżki plików zaktualizowane)*  
*Zaktualizowany: 2026-03-03 (sekcja 20 — audyt cross-check canary/ vs canary_test/, ikony statusu ✅🟠🔴⏳ w całym dokumencie, korekta statusów Faz C/D/E)*  
*Zaktualizowany: 2026-03-03 (FIX-AUD5/9/13/14/15/17/18/19 — 8 fixów launcherowych: launcher_config.json keys, fail-closed API, channel-aware manifest, loadBox race, host:port parsing, deploy error checking)*  
*Zaktualizowany: 2026-03-03 (GUARD-FIX + X8 + CFG-KEY — guardy D2-D7 naprawione, OpenSSL w vcpkg+CMake, 3 config keys ticketMaxAge/ticketClockTolerance/worldId, commit `dfe1a8784`)*  
*Następny krok: GHA kompilacja (A8+C6) → schema SQL (DB) → E13 hosting → testy D11*

---

## 20. 🔴 Audyt cross-check: canary/ vs canary_test/ (2026-03-03)

> **Źródło**: Cross-check wykonany przez Copilot (Claude) na podstawie pliku `03_AUDYT_PRAC_COPILOT_CLAUDE.md` (20 findings Codex, 3 rundy) oraz bezpośredniego porównania kodu `canary/` vs `canary_test/`.
> **Wniosek**: Codex ma rację — canary_test/ ma poważne błędy, których canary/ nie ma.

### 20.1 🔴 KRYTYCZNE — blokery kompilacji (nie przejdzie build)

| # | Problem (audyt) | Potwierdz.? | Szczegóły |
|---|-----------------|-------------|-----------|
| #1, #2 | `parseUseItem` używa `fromPos`, `fromItemId` — niezdefiniowane | ✅ TAK | `protocolgame.cpp:1992` — zmienne lokalne to `pos`, `itemId`. W canary/ ten guard nie istnieje w parseUseItem (plan: blokuj w parseUseWithCreature) |
| #2 | `parseUseItemEx` używa `itemId` — niezdefiniowane | ✅ TAK | `protocolgame.cpp:2012` — lokalna to `fromItemId`. W canary/ L1904: poprawnie `Items[fromItemId]` |
| #3, #8 | D4 Market guard osierocony (poza funkcją) | ✅ TAK | `protocolgame.cpp:3409` — blok `if (isClassic74Blocked("Market"))` stoi MIĘDZY `parsePreyAction()` a `parseSendResourceBalance()`. NIE jest wewnątrz żadnej metody. W canary/ poprawnie wewnątrz `parseMarketLeave()` |

### 20.2 🟠 WYSOKIE — guardy w złych metodach

| # | Problem | Potwierdz.? | canary_test/ | canary/ (poprawne) |
|---|---------|-------------|-------------|-------------------|
| #3 | D5 Prey guard w pętli bestiary | ✅ TAK | `protocolgame.cpp:3332` — wewnątrz pętli for w `parseBestiarySendCreatures` | `protocolgame.cpp:3286` — na wejściu `parsePreyAction()` |
| #4 | Brak guarda `parseUseWithCreature` | ✅ TAK | `protocolgame.cpp:2026` — zerowy guard | `protocolgame.cpp:1922` — guard D2 poprawnie |
| #4 | Brak guarda `parseQuickLoot` | ✅ TAK | `protocolgame.cpp:2088` — brak guarda | `protocolgame.cpp:1985` — guard D3 poprawnie |
| #4 | Brak guarda `parsePreyAction` | ✅ TAK | `protocolgame.cpp:3389` — brak guarda | `protocolgame.cpp:3286` — guard D5 poprawnie |
| #4 | Brak guarda `parseMarketLeave` | ✅ TAK | `protocolgame.cpp:3466` — brak guarda | `protocolgame.cpp:3363` — guard D4 poprawnie |
| #8 | D3 Quick Loot guard w `parseUpdateContainer` | ✅ TAK | `protocolgame.cpp:2045` — blokuje update container | canary/ nie ma guarda na parseUpdateContainer (poprawnie) |
| #8 | D3 Auto Loot guard w `parseLookAt` | ✅ TAK | `protocolgame.cpp:2074` — blokuje PATRZENIE na przedmioty! | canary/ nie ma guarda na parseLookAt (poprawnie) |
| D7 | Smart Equip guard w `default:` case switcha | ✅ TAK | `protocolgame.cpp:1606` — wewnątrz `default:` zamiast w `parseHotkeyEquip` | `protocolgame.cpp:1519` — wewnątrz `parseHotkeyEquip()` poprawnie |

### 20.3 🟡 ŚREDNIE-WYSOKIE — konfiguracja / API

| # | Problem | Potwierdz.? | Szczegóły |
|---|---------|-------------|-----------|
| #14 | Niespójny `launcher_config.json` vs `launcher.py` | ✅ FIXED | FIX-AUD14 (`6584a0187`) — apiUrl→apiBaseUrl, clientFolder→clientDir, clientExecutable→clientExe |
| #20 | Brak `ticketMaxAge`, `ticketClockTolerance`, `worldId` w config | ✅ FIXED | CFG-KEY (`dfe1a8784`) — dodano 3 klucze + ticket_validator.cpp je używa |
| X8 | Brak OpenSSL w `vcpkg.json` / CMake | ✅ FIXED | X8 (`dfe1a8784`) — `openssl` w vcpkg.json + `OpenSSL::Crypto` w CanaryLib.cmake |
| #7 | ServerList keying — dwa servery na tym samym host nadpisują się | ✅ FIXED | FIX-AUD7 — `servers[host]` → `servers[host:port]` w serverlist.lua |
| #11 | Nonce replay po restarcie — in-memory mapa się czyści | ✅ FIXED | FIX-AUD11 — DB-backed nonce check w ticket_validator.cpp (SELECT + INSERT IGNORE `ticket_nonces`) |
| #12 | `REMOTE_ADDR` bez trusted proxy policy | ✅ FIXED | FIX-AUD12 — `getClientIp($ENV)` w common.php z TRUSTED_PROXIES (CF/nginx/XFF + CIDR) |
| #16 | Puste `gameMode` → wszystkie postacie `worldId=0` | ✅ FIXED | FIX-AUD16 — `world_id` z DB players + fallback, migracja SQL |

### 20.4 Podsumowanie statusu REALNEGO

| Warstwa | Status REALNY | Blokery |
|---------|--------------|---------|
| Serwer C++ (canary_test/) | ✅ Naprawiony | GUARD-FIX (`dfe1a8784`): zmienne poprawione, osierocony kod usunięty |
| Serwer C++ guardy D2-D7 | ✅ Naprawione | Guardy we właściwych metodach: D2(parseUseItemEx/parseUseWithCreature), D3(parseQuickLoot/parseLootContainer), D4(parseMarketLeave), D5(parsePreyAction), D7(parseHotkeyEquip) |
| Serwer C++ (canary/) | 🟢 Poprawny (referencja) | Guardy we właściwych metodach, zmienne poprawne |
| Launcher config | ✅ Naprawiony | FIX-AUD14: klucze zsynchronizowane z launcher.py |
| API fail-closed | ✅ Naprawione | FIX-AUD5/13/17/18: brak hardcoded fallback, channel-aware, fail-closed |
| Deploy script | ✅ Naprawiony | FIX-AUD19: error checking + exit code |
| UI ticket flow | ✅ Naprawiony | FIX-AUD15: loadBox race fix + FIX-AUD9: host:port parsing |
| OpenSSL linkowanie | ✅ Jawne | X8 (`dfe1a8784`): `openssl` w vcpkg.json + `OpenSSL::Crypto` w CMake |
| ServerList keying | ✅ Naprawione | FIX-AUD7: `host:port` composite key zamiast `host` |
| Nonce DB persistence | ✅ Naprawione | FIX-AUD11: DB-backed nonce check w ticket_validator.cpp |
| Trusted proxy IP | ✅ Naprawione | FIX-AUD12: `getClientIp($ENV)` z TRUSTED_PROXIES w common.php |
| worldId mapping | ✅ Naprawione | FIX-AUD16: `world_id` z DB + fallback + migracja SQL |
| DB schema | ✅ Gotowe | `sql/ticket_gate_migration.sql`: launch_tokens, manifest_versions, ticket_sessions, ticket_nonces, players.world_id |
| Config ticket-gate | ✅ Kompletny | CFG-KEY (`dfe1a8784`): 5/5 kluczy (ticketGateEnabled, ticketSecret, ticketMaxAge, ticketClockTolerance, worldId) |
## 21. Aktualizacja 2026-03-05 — Canary build blocker + spójność ticket-gate

### 21.1 Co zrobiono
- Zdiagnozowano ostatni fail `Canary - Build` (`22695571939`, commit `74574f49a`):
  - `invalid use of incomplete type 'class RSA'`
  - `conflicting declaration 'typedef struct rsa_st RSA'`
- Naprawiono bloker kompilacji w `canary_test/src`:
  - `canary_server.hpp/.cpp`: `RSA&` -> `CanaryRSA&`
  - `networkmessage.hpp`: usunięto `class RSA;`
- Domknięto spójność bezpieczeństwa ticket-gate po stronie API+Canary:
  - `ticket.php`: payload ma `worldId` + `iat` (zachowany `issuedAt` dla compat), brak pre-insert nonce
  - `ticket_validator.cpp`: consume nonce po stronie Canary (DB + cache), fail-closed na błędach nonce DB, obsługa `iat/issuedAt` dla `ticketMaxAge`
  - schema/migration comments zaktualizowane do nowego modelu replay-protection

### 21.2 Co będzie robione dalej (bezpośrednio)
1. Push poprawek na `feature/ticket-gate`.
2. Uruchomienie nowego runa `Canary - Build` (workflow `231874122`).
3. Po wyniku runa: dopisanie PASS/FAIL + ewentualny kolejny hotfix do `02_DZIENNIK_BUILDOW_GHA.md`.

### 21.3 Status operacyjny
- Build blocker C++: ✅ naprawiony w kodzie lokalnym.
- Ticket-gate runtime consistency (nonce/iat/world binding): ✅ poprawione.
- Walidacja końcowa: ⏳ oczekuje na nowy run GHA Canary matrix.

## 22. Aktualizacja 2026-03-05 13:08 — stan po pushu + backlog decyzji

### 22.1 Stan bieżący (as-is)
- Poprawki krytyczne zostały wypchnięte: commit `652c0e033` na `feature/ticket-gate`.
- Run Canary został odpalony: `22717070014`.
- Zgodnie z decyzją operacyjną w tej sesji: **nie monitorujemy teraz wyniku GHA** (build 30-40 min).

### 22.2 Co można robić teraz (bez czekania na GHA)
| ID | Zadanie | Efekt bezpieczeństwa / jakości | Czas |
|---|---|---|---|
| P1 | Twardy rollout SQL (prod + rollback) | Mniejsze ryzyko awarii przy migracji `ticket_nonces/sessions/launch_tokens` | 1-2h |
| P2 | Testy replay i czasu dla ticketów | Potwierdzenie, że nonce replay i expired/clock-skew są fail-closed | 2-3h |
| P3 | Structured logging odrzuceń ticket | Lepsza diagnostyka cheat prób i szybsze reagowanie operacyjne | 2h |
| P4 | Runbook fresh install (API+Canary+launcher) | Powtarzalne wdrożenia bez „ukrytej wiedzy” i szybszy onboarding | 2-3h |
| P5 | Hardening launchera (artefakty + checksums + podpis) | Trudniejsze podmiany binarek i pewniejszy update channel | 2-4h |
| P6 | Rozdzielenie `apiPort`/`gamePort` w całym flow | Mniej błędów konfiguracji i mniej false-negative w połączeniach | 1-2h |

### 22.3 Rekomendowana kolejność do decyzji
1. `P1` SQL rollout + rollback.
2. `P2` testy replay/time-skew.
3. `P3` logging odrzuceń ticket.
4. `P4` runbook fresh install.
5. `P5` packaging/podpis launchera.
6. `P6` cleanup konfiguracji portów.

## 23. Aktualizacja 2026-03-05 15:42 — Postęp P1 (Codex)

### 23.1 Status P1
- `P1` rozpoczęte: ✅ implementacja plików migracji i runnera CLI zakończona.
- `P1` wdrożenie produkcyjne: ⏳ oczekuje na decyzję Copilot/user (uruchomienie `rollout` na docelowej DB).

### 23.2 Artefakty P1
- `canary_test/html_copy/apik/v1/migrations/001_ticket_gate_rollout.sql`
- `canary_test/html_copy/apik/v1/migrations/001_ticket_gate_rollback.sql`
- `canary_test/html_copy/apik/v1/migrations/002_launcher_tables_rollout.sql`
- `canary_test/html_copy/apik/v1/migrations/002_launcher_tables_rollback.sql`
- `canary_test/html_copy/apik/v1/migrations/003_cleanup_events_rollout.sql`
- `canary_test/html_copy/apik/v1/migrations/003_cleanup_events_rollback.sql`
- `canary_test/html_copy/apik/v1/migrations/migrate.php`

### 23.3 Walidacja wykonana
- `php -l migrate.php` — OK.
- `php migrate.php status` — OK (001/002/003 jako `PENDING`).

### 23.4 Problemy wykryte (do wspólnego rozwiązania z Copilotem)
1. Event scheduler:
`003_cleanup_events` wymaga działającego `event_scheduler`; w części środowisk potrzebne będą uprawnienia DBA do `SET GLOBAL event_scheduler = ON`.
2. Podwójne źródła schemy:
historycznie istnieją równolegle `schema_ticket_gate.sql`, `schema_launcher.sql` i `sql/ticket_gate_migration.sql`; trzeba utrzymać jeden canonical flow wdrożeniowy (rekomendacja: `apik/v1/migrations/` + `migrate.php`).
3. Spójność manifest_versions:
`generate_manifest.php` używa `file_count` i `total_size` — migracja 002 została pod to dopasowana, ale wymaga potwierdzenia po rollout.

## 24. Aktualizacja 2026-03-05 15:48 — Postęp P3 (structured logging)

### 24.1 Status P3
- `P3` wdrożone: ✅ logging w `ticket.php`, `launcher-token.php`, `challenge.php`, `server-status.php`.
- `P3` operacyjne domknięcie: ⏳ rollout/deploy po stronie hosta (katalog logów + logrotate + monitoring).

### 24.2 Co wdrożono
- `common.php`: `hashClientIp()`, `logTicketEvent()` (JSONL + fallback do `error_log`).
- `ticket.php`: eventy `ticket.issued` i `ticket.rejected.*` z metadanymi bezpieczeństwa.
- `launcher-token.php`: eventy `launcher_token.issued` i `launcher_token.rejected.*`.
- Dodano template logrotate:
  - `canary_test/html_copy/apik/v1/logrotate/serwercanary`

### 24.3 Ryzyka/otwarte decyzje
1. Domyślna ścieżka logów `/var/log/serwercanary/security-events.log` wymaga provisioning katalogu + praw (`www-data`).
2. Do potwierdzenia retencja logów i PII policy (obecnie logowane jest `ipHash`, bez surowego IP).
3. `CHALLENGE_REQUIRED` wdrażać etapowo (najpierw klienty challenge-ready, potem enforce).

## 25. Aktualizacja 2026-03-05 15:55 — Postęp P2 (testy bezpieczeństwa Rust)

### 25.1 Status
- `P2` rozpoczęte: ✅ pierwszy pakiet testów i walidacji wdrożony.
- `P2` pełne domknięcie: ⏳ nadal otwarte pozycje stricte ticket/replay po stronie API/DB (do dalszej pracy z Copilotem).

### 25.2 Co wdrożono teraz
- `launcher-api/src/client.rs`
  - twarda walidacja challenge-response:
    - nonce: non-empty, min 32 znaki, hex-only
    - TTL: `1..=30s` (odrzucane `0` i `>30`)
  - `fetch_challenge()` przechodzi przez wspólną funkcję walidacji.
  - dopisane testy jednostkowe walidacji challenge.
- `launcher-core/src/planner.rs`
  - test: absolutny URL pozostaje bez zmian (`https://...` passthrough).
  - test: brak `baseUrl` + pusty `url` w wpisie manifestu kończy się `MissingBaseUrl`.
- `common-models/src/manifest.rs`
  - test parsowania `servers[]` (id/host/port/gameMode/channel) dla manifestu v2.

### 25.3 Ryzyka / decyzje do wspólnego domknięcia
1. Limit challenge TTL na launcherze jest teraz fail-closed (`max 30s`) — API musi mieć zgodny kontrakt.
2. Jeśli produkcyjne `challenge.php` zwraca większy TTL, launcher odrzuci challenge aż do ujednolicenia konfiguracji.

## 26. Aktualizacja 2026-03-05 16:03 — Domknięcie blokad P2/P3 (challenge + server-status)

### 26.1 Co wdrożono
- `P2 2.11`: dodano test `test_challenge_with_rotated_key` w `launcher-rust/crates/launcher-core/src/hmac_rotation.rs`.
- `P3`:
  - dodano `canary_test/html_copy/apik/v1/challenge.php`,
  - dodano `canary_test/html_copy/apik/v1/server-status.php`,
  - oba endpointy logują structured eventy przez `logTicketEvent()`.
- `launcher-token.php`:
  - dodana walidacja `nonce` + `challengeResponse`,
  - one-time consume nonce z `ticket_nonces` (`account_id=0`),
  - flaga rolloutowa `CHALLENGE_REQUIRED` (domyślnie `false`).
- `.env.example`:
  - dodane `CHALLENGE_TTL`, `CHALLENGE_REQUIRED`, `SERVER_STATUS_TIMEOUT_MS`, `SECURITY_LOG_FILE`, `LOG_IP_SALT`.

### 26.2 Walidacja techniczna
- `php -l challenge.php` — OK.
- `php -l server-status.php` — OK.
- `php -l launcher-token.php` — OK.
- `rustfmt --check launcher-rust/crates/launcher-core/src/hmac_rotation.rs` — OK.

### 26.3 Otwarte decyzje operacyjne
1. `CHALLENGE_REQUIRED=true` włączyć dopiero po rollout klienta wspierającego challenge flow (żeby uniknąć `403` dla legacy).
2. Monitorować tabelę `ticket_nonces` (challenge + ticket flow) i retencję cleanup.

## 27. REALNY PLAN WYKONAWCZY — aktualizacja 2026-03-05 22:30

> **BRUTALNA DIAGNOZA**: Kod launcher-rust istnieje, Canary kompiluje się na GHA,
> ale NIE MA ŻADNEJ działającej paczki dla graczy, NIE MA drugiego serwera (Modern),
> launcher NIGDY nie został uruchomiony E2E, a hosting plików to symlinki na dev testyy/.
> Poniżej konkretne, atomowe kroki — bez ściemniania.
>
> **Poprzednia sekcja 27 (z 18:17) była za ogólnikowa** — ta ją zastępuje konkretnymi krokami.

### ~~27.2 TOR A — Instalka zwykła / dev~~ → ZASTĄPIONE przez 27.2–27.9 poniżej

> **Cała stara sekcja 27.2–27.6 jest nieaktualna — patrz sekcja 28 poniżej z konkretnymi krokami.**

### ~~27.3 TOR B — Instalka dla graczy / prod (dystrybucja)~~ → ZASTĄPIONE przez sekcję 28

| ID | Zadanie | Status |
|---|---|---|
| P-INS-1 | Build czystej paczki graczy na GHA (bez `src/`, bez plików deweloperskich) | ⬜ |
| P-INS-2 | Publikacja paczki graczy na hostingu (`/files/stable/<version>/`) | ⬜ |
| P-INS-3 | Generacja manifestu i checksum dla paczki graczy (z gotowego artefaktu) | ⬜ |
| P-INS-4 | Test świeżej instalacji z paczki graczy na Windows (bez artefaktów dev) | ⬜ |
| P-INS-5 | Rejestr wersji i changelog paczki graczy (co weszło do release) | ⬜ |
| P-INS-6 | Procedura rollback paczki graczy (rollback symlink + poprzedni manifest) | ⬜ |

### ~~27.4 TOR C — Rozdzielenie serwerów: Canary Modern i Canary 7.4~~ → ZASTĄPIONE przez sekcję 28

| ID | Zadanie | Status |
|---|---|---|
| S-1 | Ustalić finalne identyfikatory światów (`canary-modern`, `canary-classic74`) i przypisać do DB/API | ⬜ |
| S-2 | Potwierdzić osobne endpointy host:port dla `Modern` i `Classic 7.4` | ⬜ |
| S-3 | W launcherze pokazywać oba światy jako osobne pozycje (bez nadpisywania hostem) | ⬜ |
| S-4 | W `ticket.php` wymusić mapowanie `gameMode -> worldId` (bez fallbacków „wszystko”) | ⬜ |
| S-5 | Blokada cross-mode: klient `classic74` nie może wejść na `modern` i odwrotnie | ⬜ |
| S-6 | Test równoległych sesji: jednoczesny login 7.4 + modern z tej samej instalki graczy | ⬜ |

### ~~27.5 TOR D — Finalny flow: launcher update + update instalki + oba serwery~~ → ZASTĄPIONE przez sekcję 28

| ID | Zadanie | Status |
|---|---|---|
| U-1 | Test self-update launchera po podbiciu wersji (`launcher-version.php`) | ⬜ |
| U-2 | Test update instalki po zmianie pliku i podbiciu wersji manifestu | ⬜ |
| U-3 | Test „self-update + update klienta” w jednym pełnym przebiegu | ⬜ |
| U-4 | Test naprawy: modyfikacja pliku krytycznego -> blokada -> repair -> ponowny start | ⬜ |
| U-5 | Po aktualizacji uruchomić równolegle sesję `canary-modern` i `canary-classic74` | ⬜ |
| U-6 | Zapis PASS/FAIL/BLOCKED do `2026-03-05_dual_mode_test_results_J4.md` | 🔄 |

### ~~27.6 Kryteria końcowe (gate)~~ → ZASTĄPIONE przez sekcję 28

| Gate | Kryterium | Status |
|---|---|---|
| G1 | Paczka graczy uruchamia launcher bez zależności deweloperskich | ⬜ |
| G2 | Self-update launchera działa na paczce graczy | ⬜ |
| G3 | Update instalki graczy działa po zmianie manifestu | ⬜ |
| G4 | Canary Modern i Canary 7.4 są osobno widoczne i osobno osiągalne | ⬜ |
| G5 | Jednoczesna sesja 7.4 + modern z jednej instalki graczy działa | ⬜ |
| G6 | Różnice zasad bezpieczeństwa między 7.4 i modern potwierdzone testem | ⬜ |

---

## 28. KONKRETNY PLAN WYKONAWCZY (2026-03-05 22:30) — zastępuje ogólnikowe 27.2–27.6

### 28.0 STAN FAKTYCZNY — co naprawdę mamy, a czego nie

| Element | Istnieje? | Działa? | Co brakuje |
|---|---|---|---|
| Launcher Rust/Tauri — kod źródłowy | ✅ 15+ crate'ów | ❓ | NIGDY nie odpalony E2E |
| Launcher — artefakty ZIP z GHA | ✅ 6 zipów (tauri/cli/helper × win/linux) | ❓ | Nikt nie rozpakował i nie uruchomił |
| API PHP (login/ticket/update/server-status/challenge) | ✅ wdrożone /var/www/html | ⚠️ testowane curl-em | Nie testowane launcherem |
| Canary binary (serwer "7.4 test") | ✅ 153MB z GHA build #29 PASS | ⚠️ nie odpalony z ticket-gate | Brak testu z ticket flow |
| **Canary Modern (drugi serwer)** | ❌ NIE ISTNIEJE | ❌ | Osobny katalog, config, port, world w DB |
| OTClient binary (otclient + otclient.exe) | ✅ | ❓ | Nie testowane z ticket flow |
| **Paczka dla graczy** | ❌ NIE ISTNIEJE | ❌ | Brak katalogu z czystymi plikami (bez src/git/docs) |
| **Hosting plików klienta** | ⚠️ symlinki na testyy/ (dev!) | ❌ FAKE | Trzeba prawdziwą paczkę z manifestem |
| Dual-server .env config | ⚠️ porty ZAKOMENTOWANE | ❌ | Odkomentować + ustawić porty |
| Self-update launchera | ⚠️ kod istnieje | ❌ NIGDY testowany | - |
| Update instalki (patching) | ⚠️ kod istnieje | ❌ NIGDY testowany | - |
| DB tables (ticket_nonces, ticket_sessions, launch_tokens, manifest_versions) | ✅ | ⚠️ dane z curl | - |

### 28.1 TOR A — Dual-Server: uruchomienie 2 instancji Canary (Modern + Classic 7.4)

**Stan:** ✅ ZROBIONE (2026-03-05). Oba serwery chodzą: Classic PID 21040 (7171/7172), Modern PID 22305 (7173/7174). API routuje poprawnie.

| ID | Zadanie | Plik(i) | Status |
|---|---|---|---|
| S-1 | Utworzyć `canary_modern/` z osobnym `config.lua` (serverName="Canary Modern", login=7173, game=7174, ticketGateEnabled=true, worldId=1) | `canary_modern/config.lua` | ✅ |
| S-2 | Skopiować binary Canary do `canary_modern/` + podlinkować data pack | `canary_modern/` | ✅ |
| S-3 | Utworzyć world "Modern" w DB lub osobną bazę `canary_modern_db` | MySQL | ✅ db=canary_modern |
| S-4 | W `canary_test/config.lua` potwierdzić worldId=0 + game port 7172 (spójnie z API mapowaniem) | `canary_test/config.lua` | ✅ |
| S-5 | W `.env` API ODKOMENTOWAĆ: `WORLD_CLASSIC74_PORT=7172`, `WORLD_MODERN_PORT=7174` | `/var/www/html/apik/v1/.env` | ✅ |
| S-6 | Zweryfikować `login.php`: filtrowanie worldów per gameMode → poprawne IP:port | `login.php` | ✅ |
| S-7 | Uruchomić OBA serwery jednocześnie (7172 + 7174) | terminal | ✅ |
| S-8 | Test curl: login z gameMode=classic74 → world 7172; gameMode=modern → 7174 | curl | ✅ |
| S-9 | Test curl: ticket.php generuje ticket z poprawnym worldId per gameMode | curl | ✅ |

### 28.2 TOR B — Launcher: pierwsze uruchomienie i test E2E

**Stan:** CLI launcher działa na WSL (check/update/hash OK). Tauri wymaga WebKit (brak na WSL). Testy Tauri UI → **Windows** (`testy-kopia otclient`). Dodano `--dev-mode` flagę do CLI (commit be239e86e).

| ID | Zadanie | Plik(i) | Status |
|---|---|---|---|
| L-1 | Rozpakować `launcher-tauri-linux-x86_64.zip` do katalogu testowego | zip | ✅ |
| L-2 | Umieścić `launcher_config.json` (devMode=true, apiBaseUrl na serwer) obok binary | config | ✅ |
| L-3 | Uruchomić launcher Tauri — czy UI się otwiera? | terminal | ⚠️ Tauri=FAIL (brak WebKit na WSL), CLI=OK |
| L-4 | Jeśli L-3 FAIL → spisać błędy, zdiagnozować, naprawić | docs | ✅ dodano --dev-mode do CLI |
| L-5 | UI: launcher łączy się z server-status.php i widzi oba serwery? | UI | ⬜ → Windows |
| L-6 | UI: launcher pobiera manifest z update.php i widzi listę plików? | UI | ⬜ → Windows |
| L-7 | Przycisk „Graj" uruchamia OTClient z launch-tokenem? | UI+proces | ⬜ → Windows |
| L-8 | **Na Windows**: powtórzyć L-2..L-7 z launcher-tauri-windows-x86_64.zip | Windows | ⬜ → Windows (testy-kopia otclient) |

### 28.3 TOR C — Prawdziwy hosting plików klienta

**Stan:** ✅ ZROBIONE (2026-03-05). Czysta paczka 7224 plików / 432MB w `client_pack/1.1.0/`. Manifest v1.1.1 wygenerowany (hash=89d86ba3...). H-6 test launcher download → **Windows**.

| ID | Zadanie | Plik(i) | Status |
|---|---|---|---|
| H-1 | Zdefiniować zawartość paczki graczy (otclient.exe + data/ + modules/ + init.lua, BEZ src/git/docs) | docs | ✅ |
| H-2 | Napisać `build_client_pack.sh` kopiujący TYLKO wymagane pliki | skrypt | ✅ |
| H-3 | Wygenerować manifest na czystej paczce (generate_manifest.php) | API | ✅ v1.1.1 |
| H-4 | Umieścić pod `/files/stable/1.1.0/` (prawdziwy katalog, NIE symlink) | serwer www | ✅ |
| H-5 | Wpis do `manifest_versions` w DB | MySQL | ✅ |
| H-6 | Test: launcher pobiera manifest → pliki → filesHash OK → token OK | launcher | ⬜ → Windows |

### 28.4 TOR D — Self-update launchera

**Stan:** API gotowe (sha256 dodane). CLI check działa — widzi version mismatch i required=true/false. SU-4/SU-5 wymagają nowego builda → po zakończeniu wszystkich zadań.

| ID | Zadanie | Plik(i) | Status |
|---|---|---|---|
| SU-1 | Ustawić poprawny response w launcher-version.php (version, downloadUrl, sha256) | API | ✅ sha256 dodane |
| SU-2 | Sprawdzić curl → poprawny JSON | curl | ✅ |
| SU-3 | Launcher v0.1.0 → "Brak aktualizacji" (wersja ta sama) | launcher | ✅ CLI check potwierdza |
| SU-4 | Podbić na v0.2.0 w API, zbudować nowy launcher na GHA, wgrać binary | GHA+serwer | ⬜ wymaga builda |
| SU-5 | Stary launcher → "Aktualizuj" → podmiana → restart OK | launcher | ⬜ → Windows |

### 28.5 TOR E — Update instalki klienta po zmianach

**Stan:** Przetestowano na WSL z CLI launcher: zmiana init.lua → nowy manifest v1.1.1 → launcher wykrywa 1 plik do update → pobiera → SHA OK. UP-5 (uruchomienie gry) → **Windows**.

| ID | Zadanie | Plik(i) | Status |
|---|---|---|---|
| UP-1 | Zmienić 1 plik w paczce klienta (np. init.lua) | client_pack/ | ✅ |
| UP-2 | Podbić manifest (1.1.0 → 1.1.1), wygenerować nowy | generate_manifest + DB | ✅ naprawiono POST parsing |
| UP-3 | Launcher wykrywa "Update dostępny" → "Aktualizuj" | launcher UI | ✅ CLI: 1 download, up_to_date=false |
| UP-4 | Launcher pobrał zmieniony plik, SHA OK, nowy filesHash OK | launcher logs | ✅ init.lua pobrany, hash=89d86ba3 |
| UP-5 | Gra po aktualizacji → login → serwer | OTClient | ⬜ → Windows |

### 28.6 TOR F — Paczka graczy finalna (produkcyjna instalka)

**Stan:** Struktura Linux gotowa (`player_package/`): launcher + launcher-cli + configs + client/. ZIP=7.9MB. Paczka Windows → z `testy-kopia otclient` + launcher-tauri-windows.

| ID | Zadanie | Plik(i) | Status |
|---|---|---|---|
| PK-1 | Struktura: launcher.exe + client/ + launcher_config.json | - | ✅ Linux gotowe |
| PK-2 | launcher_config.json z URL produkcyjnym (devMode=false) | config | ✅ + dev wariant |
| PK-3 | Spakować w ZIP / instalator | - | ✅ TwojaGra-Linux-v1.0.0.zip (7.9MB) |
| PK-4 | Test E2E: gracz pobiera → rozpakowuje → launcher → update → gra | test | ⬜ → Windows |
| PK-5 | Test: nowy gracz bez historii — paczka self-sufficient? | test | ⬜ → Windows |

### 28.7 Kryteria końcowe — G1..G9 WSZYSTKIE ✅ = "działa"

| Gate | Kryterium | Zależy od | Status |
|---|---|---|---|
| G1 | Oba serwery (Modern 7174 + Classic74 7172) chodzą jednocześnie | S-7 | ✅ |
| G2 | Launcher Tauri na Windows pokazuje ekran + status obu serwerów | L-8 | ⬜ → Windows |
| G3 | Launcher pobiera pliki z prawdziwego manifestu (nie symlinki) | H-6 | ✅ CLI (WSL) potwierdza |
| G4 | Self-update launchera: stara → nowa wersja | SU-5 | ⬜ wymaga builda |
| G5 | Update instalki: zmiana → nowy manifest → launcher patchuje | UP-5 | ✅ CLI (WSL) potwierdza |
| G6 | Classic74: login → ticket → serwer 7172, blokady działają | S-9+UP-5 | ⬜ → Windows |
| G7 | Modern: login → ticket → serwer 7174, bez blokad | S-9+UP-5 | ⬜ → Windows |
| G8 | Paczka graczy ZIP: rozpakuj → uruchom → graj | PK-5 | ⬜ → Windows |
| G9 | Cross-mode block: classic74 ≠ modern i odwrotnie | S-5 | ✅ API routuje poprawnie |

### 28.7a J7 — dev vs prod (status dokumentacyjny)

| ID | Zadanie | Artefakt | Status |
|---|---|---|---|
| J7.0 | Spisać różnice instalka `dev` vs `gracze/prod` (kanały, katalogi, zasady rollout) | `../../Dokumentacja/2026-03-05_instalka_dev_vs_gracze_J7.md` | ✅ |
| J7.1 | Przełożyć dokument na wdrożenie konfiguracji i smoke testy (L/H/PK) | sekcje 28.2, 28.3, 28.6 | ⏳ |

### 28.8 Kolejność realizacji (sugerowana)

```
1. TOR A (Dual-Server) → S-1..S-9
   ↓ oba serwery chodzą, API zwraca poprawne porty
2. TOR C (Hosting plików) → H-1..H-6
   ↓ prawdziwa paczka z manifestem
3. TOR B (Launcher E2E) → L-1..L-8
   ↓ launcher uruchamia się, widzi serwery, pobiera pliki, odpala grę
4. TOR D (Self-update) → SU-1..SU-5
   ↓ stary launcher podmienia się na nowy
5. TOR E (Update instalki) → UP-1..UP-5
   ↓ zmiana pliku → nowy manifest → launcher patchuje → gra działa
6. TOR F (Paczka graczy) → PK-1..PK-5
   ↓ self-sufficient ZIP dla gracza
```

### 28.9 TOR G — Wspolne konto na 2 serwery + strona/launcher (NOWE wymaganie 2026-03-05)

**Stan:** brak domknietej logiki `konto wspolne + wybor serwera po loginie + topki/listy all/per-serwer`.

| ID | Zadanie | Plik(i) | Status |
|---|---|---|---|
| K-1 | Login: sesja neutralna `gameMode=all` (gdy user nie wybral serwera) zamiast domyslnego `modern` | `login.php` | 🟢 (repo) |
| K-2 | Ticket: dla sesji `all` wymagac `gameMode` i walidowac postac do wybranego serwera | `ticket.php` | 🟢 (repo) |
| K-3 | Ujednolicic mapowanie `gameMode↔worldId↔worldName` we wszystkich endpointach | `login.php`, `ticket.php`, `server-status.php`, `generate_manifest.php` | 🟢 (repo) |
| K-4 | Potwierdzic kolumne bazy dla swiata postaci (`players.world`, fallback kompatybilnosci) | API + SQL | 🟢 (diagnoza + fallback w repo) |
| K-5 | Dodac endpoint rejestracji konta pod launcher (`register-account.php`) | API | 🟢 (repo) |
| K-6 | Dodac endpoint kontekstu konta i wyboru serwera (`account-context.php`) | API | 🟢 (repo) |
| K-7 | Dodac endpoint topki `all/classic74/modern` | API | 🟢 (repo) |
| K-8 | Dodac endpoint listy graczy `all/classic74/modern` | API | 🟢 (repo) |
| K-9 | Wpisac kontrakt JSON dla strony i launchera (jeden format danych) | docs | ✅ |
| K-10 | Testy curl + raport PASS/FAIL/BLOCKED | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` | 🔄 (lokalne testy kontraktu PASS, w tym K12 + K13/K14) |
| K-11 | Migracja DB identity/social/sync (`004_identity_social`) | `migrations/004_*` | ✅ (APPLIED 2026-03-05 19:12) |
| K-12 | Sync token WWW↔launcher: issue/consume endpointy | API | 🟢 (repo + testy lokalne PASS) |
| K-13 | Flow launcher->WWW: konto zalozone w launcherze, postacie tworzone na WWW | API + WWW | 🟢 (repo + test lokalny PASS) |
| K-14 | Flow WWW->launcher: konto zalozone na WWW synchronizowane do launchera | API + launcher | 🟢 (repo + test lokalny PASS) |
| K-15 | Social auth launcher: Google/Facebook/Steam (link/create konto lokalne) | API + launcher | 🔄 backend dla Google/Facebook/Steam gotowy w repo (`oauth-start.php`, `oauth-callback.php`), runtime/secrets/E2E pending |
| K-16 | Hardening social/sync: PKCE + state/nonce + rate-limit + audit trail | API + DB | 🔄 czesciowo (PKCE oauth2 + one-time state + audit + anti-merge-collision + DB rate-limit w repo; migracja 005 pending), pelny pakiet TODO |
| K-17 | UX launcher-first: po rejestracji 2 akcje `Utworz postac Tibia 7.4` / `Utworz postac Modern` + redirect WWW z preselectem swiata | launcher + WWW | 🟢 (repo, runtime test pending) |
| K-18 | Launcher: `Utworz postac` probuje auto-login WWW przez `account-sync-token.php` (gdy jest `sessionKey`) i fallbackuje do zwyklego URL przy bledzie | launcher-tauri + API | 🟢 (repo, runtime test pending) |
| K-19 | Natywny login konta launchera (email+haslo -> `sessionKey` bez recznego wklejania) | launcher UX/auth | 🟢 kod gotowy (repo): formularz UI + komenda Tauri, runtime E2E pending |
| K-20 | Spec globalnego konta launchera dla wielu gier (`identity` + profile per gra/serwer) | API + docs | ⬜ TODO |
| K-21 | Security scope multi-game (identity token vs profile token + audit) | API + docs | ⬜ TODO |
| K-22 | Gildie: model globalny + odwzorowanie per gra/serwer | API + WWW | ⏸ DEFERRED (po stabilizacji login/security) |
| K-23 | UI aren | launcher + WWW | ⏸ DEFERRED (po stabilizacji login/security) |
| K-24 | Natywna rejestracja konta launchera (`accountName/email/password/passwordConfirm`) + auto-login + fallback | launcher UX/auth | 🟢 kod gotowy (repo), runtime E2E pending |
| K-28 | Ujednolicenie rejestracji WWW/API (walidacja + pola konta) | WWW + API | 🟢 kod gotowy (repo), runtime E2E pending |
| K-29 | Portal `RedDAXE.pl` jako front-door (download launcher + konto + nawigacja) | WWW | ✅ RUNTIME PASS (`/portal/index.php` HTTP 200) |
| K-30 | `RedDAXE.pl` download launchera: artefakt + checksum + fallback link | WWW + API | ✅ RUNTIME PASS (`/portal/download.php` HTTP 200, SHA-256 widoczny) |
| K-31 | `RedDAXE.pl` konto wspolne (rejestracja/logowanie) na tym samym backendzie `accounts` | WWW + API | ✅ RUNTIME PASS (register+login portal) |
| K-32 | `RedDAXE.pl` bezpieczne redirecty do WWW/forum/wiki/external (allow-list) | WWW | ✅ RUNTIME PASS (allow-list 302, open-redirect 400) |
| K-33 | Testy pre-kompilacyjne E2E dla portalu (konto + download + routing) | testy runtime | ✅ RUNTIME PASS |
| K-34 | Spojnosc brandingu/copy: `RedDAXE.pl` <-> WWW gry <-> launcher | WWW + docs | 🔄 W TRAKCIE (MVP copy gotowe; pelna standaryzacja po i18n) |
| K-35 | Spike architektury front-door: PHP vs Python+Django (koszt, ryzyko, migracja) | architektura + docs | ⬜ TODO |
| K-36 | Model globalnych rang (Helper/Admin/Multiadmin) per gra/serwer | authz + docs | ⬜ TODO (etap pozniejszy) |
| K-37 | Federacja rang do forum/serwisow zewnetrznych (badge/title sync API) | API + forum | ⬜ TODO (po wyborze forum) |
| K-41 | Pelne i18n portalu RedDAXE (`/portal` + `/reddaxe`): slowniki, selector jezyka, fallback | WWW + i18n | 🔄 PARTIAL — `/portal` runtime PASS; `/reddaxe` i18n wdrozone (PL/EN + selector + fallback), lokalny smoke PASS, runtime smoke pending |
| K-42 | Pelne i18n WWW Tibia (CanaryAAC): account/create-character/toplist/players-list + bledy | WWW + i18n | ⬜ TODO (must-have) |
| K-43 | Matryca testow i18n E2E (launcher+portal+WWW): PL/EN + fallback + missing keys | QA + i18n | 🔄 PARTIAL — `/portal` + AAC PASS, `/reddaxe` lokalny smoke PASS po i18n, launcher + runtime smoke `/reddaxe` pending |
| K-47 | Architektura 2 baz serwerow: `global accounts` + `game_classic74` + `game_modern` | DB + arch | ⬜ TODO (spec) |
| K-48 | Migracje infra/ENV: osobne DSN dla baz `classic74` i `modern` | DB + API | ⬜ TODO |
| K-49 | Warstwa read/write routing po `gameMode` (repozytoria per-serwer) | API + WWW | ⬜ TODO |
| K-50 | Mapowanie kont globalnych do profili per-baza (`account_world_links`) | DB + API | ⬜ TODO |
| K-51 | API agregacji `all/classic74/modern` nad 2 bazami z tagiem zrodla rekordu | API | ⬜ TODO |
| K-52 | Jedna strona WWW nad 2 bazami (switch serwera + degraded mode) | WWW | ⬜ TODO |
| K-53 | Checkout sklepu SMS z twardym kontekstem serwera/bazy | WWW + platnosci | 🔄 SPEC READY (`05_PLAN_SKLEP_SMS_2_BAZY.md`) |
| K-54 | Callback SMS: idempotencja + podpis + anti-replay + routing creditu | API + platnosci | 🔄 PARTIAL — callback core wdrozony (`CallbackProcessor` + PayPal/MercadoPago/PagSeguro), runtime E2E + signature hardening pending |
| K-55 | Historia zakupow `all` + filtry per-serwer + audit | WWW + DB | 🔄 PARTIAL — audit ledger schema + callback write do `payment_ledger_entries` wdrozone, read-model pending |
| K-56 | Rekonsyliacja transakcji (worker/cron) provider <-> DB | API + ops | 🔄 SPEC READY (`05_PLAN_SKLEP_SMS_2_BAZY.md`) |
| K-57 | Matryca testow E2E bez kompilacji (register/login/characters/shop SMS, 2 bazy) | QA | 🔄 SPEC READY (`05_PLAN_SKLEP_SMS_2_BAZY.md`) |
| K-58 | Plan migracji danych 1-baza -> 2-bazy + rollback | DB + ops | 🔄 SPEC READY (`05_PLAN_SKLEP_SMS_2_BAZY.md`) |
| K-59 | Monitoring i alerty (DB health, callback SMS fail, duplicate txn) | ops | 🔄 SPEC READY (`05_PLAN_SKLEP_SMS_2_BAZY.md`) |
| K-60 | Runbook operacyjny (onboarding nowej bazy/serwera + recovery) | ops + docs | 🔄 DRAFT READY (`05_PLAN_SKLEP_SMS_2_BAZY.md`) |

**Uwaga operacyjna (2026-03-05):**
- ✅ Runtime deploy plikow PHP do `/var/www/html/apik/v1/` nie jest obecnie blokerem uprawnien (grupa `www-data` + deploy przez `cp/install`).
- Dla K-13/K-14 dodano endpointy mostu sesji WWW: `account-sync-www-login.php` (consume + auto-login WWW) i `account-sync-www-token.php` (issue z aktywnej sesji WWW).
- Dla K-15 dodano backend social callback/start dla providerow Google/Facebook/Steam: `oauth-start.php` + `oauth-callback.php` (link/create lokalnego konta, sesja launchera, opcjonalny deep-link powrotu do launchera).
- Dla K-16 dodano migracje `005_oauth_rate_limit_*` i DB-backed rate-limit w `oauth-start.php` / `oauth-callback.php` (feature flag `OAUTH_RATE_LIMIT_ENABLED`).
- Dla K-18 launcher UI ma pole `sessionKey` i nowa komende Tauri `build_create_character_url`, ktora wywoluje `account-sync-token.php` i otwiera `account-sync-www-login.php` z redirectem do create-character + `mode`.
- Dodatkowo wykryto brak indeksu UNIQUE na `accounts.email` (ryzyko duplikacji emaila bez transakcyjnej ochrony DB).
- Dla K-19 launcher ma nowy formularz loginu (email+haslo) i komende `login_launcher_account`, ktora pobiera `launchToken`, loguje przez `login.php` i uzupelnia `sessionKey`.
- Dla K-24 launcher ma formularz rejestracji i komende `register_launcher_account`, ktora tworzy konto przez `register-account.php`, potem probuje auto-login i przy bledzie daje czytelny fallback do recznego loginu.
- Dla K-28 ujednolicono kontrakt rejestracji WWW/API: WWW `Create.php` ma regex `accountName` + limit hasla 6-72 + email lowercase + hash surowego hasla (bez HTML-sanitizacji), a API `register-account.php` uzupelnia ten sam zestaw pol konta (`page_access/premdays/type/coins/recruiter`).
- Nowy kierunek pre-kompilacyjny: `RedDAXE.pl` jako strona glowna testowa systemu (download launchera, wspolne konto, przejscia do WWW/forum/wiki i linkow zewnetrznych), z pelnym E2E bez kompilacji.
- Szczegolowy plan wykonawczy K-29..K-34: `Dokumentacja/01_Instalka_Klient/2026-03/04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md`.
- Dla K-29/K-30/K-32 wdrozono kod portalu i API: `reddaxe/index.php`, `reddaxe/go.php`, `reddaxe/bootstrap.php`, `apik/v1/installer-catalog.php`.
- Runtime front-door aktualnie dziala pod sciezka `https://127.0.0.1/portal/` (HTTP 301 -> HTTPS); wariant `/reddaxe/*` utrzymywany jako rownolegly modul repo.
- Dla K-41..K-43 zakres i18n portal+WWW zostal oznaczony jako gate must-have przed finalnym release.
- Dla K-41 wdrozono i18n runtime portalu `/portal`: pl/en, selector jezyka (cookie `portal_lang`) i fallback do en; testy runtime PASS.
- Dla K-41 wdrozono i18n rownoleglego modulu `/reddaxe`: slowniki `pl/en`, selector jezyka, fallback i usuniecie hardcoded PL (lokalny smoke PASS bez kompilacji).
- Dla security redirectow `/reddaxe/go.php` log nie zapisuje juz surowego IP; w `redirect.log` trafia `ipHash` (sha256 + salt z `.env`).
- Smoke K-44/K-45 (2026-03-05): API split (`/apik/v1/toplist.php`, `/apik/v1/players-list.php`) PASS; runtime WWW ma rozjazd routingu (`/community/highscores` i `/shop/payment` zwracaja 404, legacy `/index.php/highscores` zwraca 200).
- Dla nowego zakresu pre-release dopisano pakiet K-47..K-60: separacja 2 baz runtime, agregacja WWW/API i pelny sklep SMS (checkout+callback+rekonsyliacja) w modelu serwer-aware.
- Dla K-53..K-60 dodano szczegolowy plan wykonawczy: `05_PLAN_SKLEP_SMS_2_BAZY.md`.
- Przygotowano migracje `009_payment_provider_idempotency` (tabele `payment_provider_events` + `payment_ledger_entries`) pod idempotentne callbacki i audyt ksiegowania.
- Lokalny smoke (bez kompilacji): `installer-catalog.php` zwraca artefakt `launcher-main`; `go.php?to=www` zwraca `302`, a niepoprawny klucz redirectu zwraca `400`.
- Dla K-31 dodano dedykowane strony konta portalu: `reddaxe/account-create.php`, `reddaxe/account-login.php`, `reddaxe/post-login.php`.
- Rejestracja portalowa korzysta ze wspolnej uslugi `register-account-lib.php` (ta sama logika co API), co usuwa ryzyko self-HTTP deadlock przy single-worker.
- `reddaxe/post-login.php` ma przycisk generowania tokenu `WWW -> launcher` przez `account-sync-www-token.php` (potwierdzenie wspolnego konta z launcherem).
- Bloker do finalnego K-31/K-33: rozjazd stacku logowania WWW (`/account/login` vs legacy routing/template) wymaga potwierdzenia w docelowym runtime przegladarkowym.
- Wykryto luke implementacyjna: bootstrap routera aplikacyjnego (`App/Routes`) nie jest czytelny w aktualnym drzewie, dlatego portal jest wdrozony jako niezalezny moduł plikowy `/reddaxe/*` (pod vhost `RedDAXE.pl`) i nie wymaga kompilacji.
- Do backlogu dopisano etap pozniejszy: decyzja architektury `PHP vs Django` dla front-door oraz model globalnych rang z federacja na forum/serwisy zewnetrzne.
- Otwarta luka logiczna: K-19 jest jeszcze bez potwierdzonego runtime E2E (deploy + test na docelowym launcherze).
- Wymagane przez usera: konto z launchera ma dzialac na WWW (tworzenie postaci), konto z WWW ma synchronizowac sie z launcherem oraz social signup/login (Google/Facebook/Steam).
- Nowy wymog UX: po zalozeniu konta w launcherze gracz ma od razu widziec wybor `Tibia 7.4` / `Modern`, a WWW ma otwierac formularz tworzenia postaci z odpowiednim preselectem swiata.
- Dodatkowy wymog produktowy: konto launchera ma byc globalne dla wielu gier; na tym etapie domykamy security+linked accounts, a gildie i UI aren sa celowo odlozone.
