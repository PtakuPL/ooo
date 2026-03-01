# Plan zabezpieczenia klienta i serwera — ticket-gate + tryby gry + blokada dodawania serwerów
**Data**: 2026-03-01  
**Status**: PLAN IMPLEMENTACJI  
**Źródło**: zarys_planu_modyfikacji_klienta.md + analiza kodu OTClient + Canary  

---

## 0. Cel

1. **Gracz NIE MOŻE dodawać/edytować serwerów** — lista jest na sztywno sterowana przez właściciela
2. **Logowanie tylko przez ticket-gate (HMAC)** — serwer gry akceptuje WYŁĄCZNIE kryptograficznie podpisane tickety. Bez poprawnego HMAC = disconnect. To jest TWARDA bariera bezpieczeństwa.
3. **Launcher z auto-update** — gracz uruchamia launcher, który sprawdza pliki i wydaje launch-token. Launch-token to **dodatkowa warstwa UX/speed-bump**, ale NIE jest kryptograficznym dowodem oficjalnego launchera (patrz sekcja 16.3). Prawdziwą barierą jest ticket-gate.
4. **Tryb Classic 7.4** — po wybraniu gracz widzi TYLKO serwer imitacji 7.4 i nie łączy się z innymi
5. **Tryb Modern** — gracz widzi TYLKO serwer Modern i nie łączy się z serwerem 7.4
6. **Feature flags Classic 7.4** — blokada hotkey na runy, wyłączenie quick-loot, action bar itd.

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

## 2. KROK 1 — Klient: Blokada dodawania serwerów + tryby gry

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
  - Ukrywa wszystkie pola serwera (jak `setUniqueServer`)
  - Blokuje `ServerList.add()`, `ServerList.remove()`
  - Nie pozwala zmienić `G.host` ręcznie

#### C. `modules/client_serverlist/serverlist.lua` — zablokowanie
```lua
function ServerList.add(host, port, protocol, httpLogin, load)
    if CLIENT_LOCKED and not load then
        return false, 'Server list is locked'
    end
    -- ... reszta jak jest
end

function ServerList.remove(widget)
    if CLIENT_LOCKED then
        return  -- nie pozwalaj usuwać
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

## 3. KROK 2 — API HTTP: Ticket-gate (token sesyjny)

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
| `login.php` | Główny endpoint logowania — dodać gameMode + launchToken, NIE generuje ticketu | MODYFIKACJA |
| `ticket.php` | **OSOBNY endpoint** — generowanie ticketu HMAC po wyborze postaci | NOWY |
| `config.php` | Klucz tajny HMAC (`TICKET_SECRET`) | MODYFIKACJA |
| `ticket_nonces` (tabela DB) | Jednorazowe nonces — `nonce VARCHAR(64) PRIMARY KEY, expires_at INT` — konsumpcja przez atomowe DELETE | NOWE |

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

## 4. KROK 3 — Serwer Canary: Weryfikacja ticketu

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

| Plik | Opis | Typ |
|------|------|-----|
| `src/server/network/protocol/protocolgame.cpp` | Dodać ticket validation przed auth | MODYFIKACJA |
| `src/server/security/ticket_validator.h` | Struktura i deklaracja | NOWY |
| `src/server/security/ticket_validator.cpp` | Implementacja walidacji HMAC + nonce | NOWY |
| `src/config/configmanager.cpp` | Rejestracja `REQUIRE_TICKET`, `TICKET_SECRET`, `WORLD_ID` | MODYFIKACJA |
| `config.lua` | Dodanie nowych kluczy | MODYFIKACJA |
| `CMakeLists.txt` | Dodać nowy plik .cpp do buildu | MODYFIKACJA |

---

## 5. KROK 4 — Feature flags Classic 7.4

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

| Funkcja | Klient (Lua) | Serwer (C++) | Pewność |
|---------|-------------|-------------|---------|
| Hotkey na runę | Ukrywa opcję w UI | `parseUseWithCreature()` odrzuca runy z hotkey slot | **99%** |
| Quick Loot | Ukrywa przycisk | `parseQuickLoot()` → return | **100%** |
| Auto Loot | Ukrywa opcję | `parseQuickLoot()` → return | **100%** |
| Market | Nie ładuje modułu | `parseMarket*()` → return | **100%** |
| Action Bar | Ukrywa pasek | Serwer ignoruje pakiety action bar | **100%** |
| Prey | Ukrywa panel | `parsePrey*()` → return | **100%** |
| Wheel | Ukrywa panel | `parseWheel*()` → return | **100%** |
| Smart Equip | Blokuje Ctrl+klik | Odrzuca auto-equip opcode | **100%** |
| Rune cooldown | Komunikat "poczekaj" | 1000ms min między użyciami | **100%** |
| Bestiary | Ukrywa panel | Opcjonalnie: blokuj parseBestiary | **95%** |

> **Wniosek**: Z serwerową blokadą nawet **w pełni zmodyfikowany klient** NIE może obejść ograniczeń Classic 7.4. Pakiety są odrzucane zanim dotą do logiki gry.

---

## 6. Kolejność implementacji (chronologicznie)

### Faza A — Klient UX (tydzień 1) — BEZ zmian serwera
| # | Zadanie | Trudność | Czas |
|---|---------|----------|------|
| A1 | Dodać `CLIENT_LOCKED` + `GameModes` do `init.lua` | ŁATWE | 30min |
| A2 | Ekran wyboru trybu (gameModePanel) w `entergame.otui` | ŁATWE | 1h |
| A3 | Logika wyboru trybu w `entergame.lua` + ustawienie serwera | ŚREDNIE | 2h |
| A4 | Zablokować `ServerList.add/remove` gdy `CLIENT_LOCKED` | ŁATWE | 15min |
| A5 | Ukryć pola serwera/portu/protokołu/http | ŁATWE | 30min (reuse setUniqueServer) |
| A6 | Feature flags: blokada hotkey items/runes w kliencie | ŚREDNIE | 2h |
| A7 | Feature flags: ukrycie modułów (action bar, market, itp.) | ŚREDNIE | 2h |
| A8 | Testowanie na Windows | - | 2h |
| | **Suma fazy A** | | **~10h** |

### Faza B — API HTTP ticket-gate 2-fazowy (tydzień 2)
| # | Zadanie | Trudność | Czas |
|---|---------|----------|------|
| B1 | Dodać `gameMode` + `launchToken` do login.php | ŁATWE | 1h |
| B2 | Filtrowanie worldów wg `gameMode` + zapisanie gameMode w sesji | ŁATWE | 1h |
| B3 | **Nowy endpoint `ticket.php`** — walidacja sesji, sprawdzenie characterName∈konto, worldId∈gameMode, generowanie ticketu HMAC | ŚREDNIE | 4h |
| B4 | Tabela `ticket_nonces` w MySQL (atomowe DELETE) | ŁATWE | 15min |
| B5 | Klient Lua: po wyborze postaci → request do ticket.php → użyj ticket jako sessionKey | ŚREDNIE | 3h |
| B6 | Klient C++: nowa metoda `requestTicket()` w httplogin.cpp/.h | ŚREDNIE | 2h |
| B7 | Testowanie flow: login → lista postaci → ticket → connect | - | 3h |
| | **Suma fazy B** | | **~14h** |

### Faza C — Serwer Canary ticket-gate (tydzień 3)
| # | Zadanie | Trudność | Czas |
|---|---------|----------|------|
| C1 | Nowy plik `ticket_validator.cpp/.h` | ŚREDNIE | 4h |
| C2 | Integracja z `protocolgame.cpp` | ŚREDNIE | 3h |
| C3 | Nowe klucze w `configmanager.cpp` | ŁATWE | 1h |
| C4 | Konfiguracja w `config.lua` | ŁATWE | 15min |
| C5 | Nonce store (in-memory lub DB) | ŚREDNIE | 2h |
| C6 | Kompilacja i test | - | 3h |
| | **Suma fazy C** | | **~13h** |

### Faza D — Feature flags serwer Canary (tydzień 4)

> Wszystkie guardy opisane w sekcji 5.3. Tryb gracza pochodzi z ticketu HMAC (Faza C).

| # | Zadanie | Trudność | Czas | Szczegóły (sekcja 5.3.x) |
|---|---------|----------|------|--------------------------|
| D1 | `GameMode` enum + pole w `Player` + setter z ticketu | ŁATWE | 1h | 5.3.1 |
| D2 | Blokada rune-on-creature hotkey (`parseUseWithCreature`) | ŚREDNIE | 3h | 5.3.2 — heurystyka `fromPos.x==0xFFFF` |
| D3 | Blokada Quick Loot + Auto Loot (`parseQuickLoot*`) | ŁATWE | 1h | 5.3.3 |
| D4 | Blokada Market — 5 metod `parseMarket*()` | ŁATWE | 1h | 5.3.4 |
| D5 | Blokada Prey System (`parsePrey*`) | ŁATWE | 30min | 5.3.5 |
| D6 | Blokada Wheel of Destiny (`parseWheel*`) | ŁATWE | 30min | 5.3.6 |
| D7 | Blokada Smart Equip (auto-equip opcode) | ŁATWE | 30min | 5.3.7 |
| D8 | Rate-limit użycia run (1000ms cooldown classic74) | ŚREDNIE | 1.5h | 5.3.8 |
| D9 | Blokada Action Bar packets | ŁATWE | 30min | — |
| D10 | Blokada Bestiary (opcjonalne) | ŁATWE | 30min | 5.3.9 |
| D11 | Pełny test integracyjny — każda blokada server-side | - | 4h | Tabela 5.3.9 |
| | **Suma fazy D** | | **~14h** |

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
| OpenSSL / libcrypto | HMAC-SHA256 w C++ (serwer) | TAK — Canary już linkuje OpenSSL |
| json library (C++) | Parsowanie ticketu na serwerze | TAK — Canary używa nlohmann/json |
| PHP hash_hmac | Generowanie ticketu w API | TAK — wbudowane w PHP |
| MySQL | Tabela nonces | TAK — istniejąca baza |

---

## 10. Docelowy test akceptacyjny

1. ✅ Gracz uruchamia klienta → widzi ekran wyboru trybu
2. ✅ Wybiera "Classic 7.4" → wypełnia login → loguje się
3. ✅ Widzi TYLKO postaci z serwera 7.4 (filtrowanie worldów)
4. ✅ Nie ma opcji dodania/edycji serwera
5. ✅ Na serwerze 7.4: hotkey na runę → komunikat "niedostępne"
6. ✅ Na serwerze 7.4: brak action bar, quick loot, market
7. ✅ Gracz z innego klienta (np. czysty OTClient) → próba loginu → odrzucona (brak ticketu)
8. ✅ Stary ticket (>30s) → odrzucony
9. ✅ Ten sam ticket użyty 2x → odrzucony (nonce)
10. ✅ Gracz w trybie "Modern" → nie łączy się z serwerem 7.4

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

| # | Zadanie | Trudność | Czas | Faza |
|---|---------|----------|------|------|
| X1 | 2-fazowy ticket: endpoint `ticket.php` + klient Lua/C++ | WYSOKIE | 6h | B |
| X2 | Włączenie TLS verification + usunięcie HTTP fallback w `httplogin.cpp` | ŚREDNIE | 2h | A |
| X3 | Pełna blokada `ServerList.init()` — ignoruj `g_settings` gdy locked | ŁATWE | 1h | A |
| X4 | Atomowy nonce (DELETE z affected_rows lub mutex) | ŁATWE | 1h | C |
| X5 | Nowa ścieżka `authType="ticket"` w `protocolgame.cpp` | WYSOKIE | 4h | C |
| X6 | Dodanie `gameMode` do `httpLogin()` C++ + Lua binding | ŚREDNIE | 3h | A |
| X7 | Usunięcie logowania haseł/ticketów w `httplogin.cpp` | ŁATWE | 30min | A |
| X8 | Dodanie OpenSSL do vcpkg.json + CanaryLib.cmake | ŁATWE | 30min | C |
| | **Suma dodatkowych zadań** | | **~18h** |

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

## 17. Faza E — Plan implementacji launchera

| # | Zadanie | Trudność | Czas |
|---|---------|----------|------|
| E1 | Skrypt `generate_manifest.php` — generowanie manifestu z katalogu | ŁATWE | 1h |
| E2 | Endpoint `GET /api/update.php` — zwraca manifest | ŁATWE | 1h |
| E3 | Endpoint `POST /api/launcher-token.php` — wydaje token | ŚREDNIE | 2h |
| E4 | Endpoint `GET /api/launcher-version.php` — wersja launchera | ŁATWE | 30min |
| E5 | Tabela `launch_tokens` w MySQL + cleanup cron | ŁATWE | 30min |
| E6 | Launcher Python: sprawdzanie plików + pobieranie | ŚREDNIE | 4h |
| E7 | Launcher Python: GUI (tkinter) + pasek postępu | ŚREDNIE | 3h |
| E8 | Launcher Python: launch-token + uruchomienie klienta | ŁATWE | 1h |
| E9 | Launcher: self-update (sprawdzanie wersji launchera) | ŚREDNIE | 2h |
| E10 | Klient: obsługa `OTC_LAUNCH_TOKEN` env variable w `init.lua` | ŁATWE | 1h |
| E11 | API `login.php`: walidacja `launchToken` przy loginie | ŚREDNIE | 2h |
| E12 | Build launchera: PyInstaller → .exe + testowanie | ŁATWE | 1h |
| E13 | Hosting plików klienta na serwerze WWW | ŁATWE | 1h |
| | **Suma Fazy E** | | **~20h** |

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

| Faza | Opis | Czas |
|------|------|------|
| A | Klient UX: tryby, blokada serwerów | ~10h |
| B | API HTTP: ticket-gate 2-fazowy | ~14h |
| C | Serwer Canary: weryfikacja ticketu | ~13h |
| D | Feature flags serwer — TWARDE blokady Classic 7.4 (sekcja 5.3) | ~14h |
| Audyt (X1-X8) | Korekty po review kodu | ~18h |
| **E** | **Launcher z auto-update** | **~20h** |
| | **ŁĄCZNIE** | **~89h (~8 tyg.)** |

### Rekomendowana kolejność:
1. **Faza A** (klient UX) — natychmiastowy efekt wizualny
2. **Równolegle: X2 + X7 + X3** — hard-fail TLS w kliencie + usunięcie logów haseł + ServerList bypass fix (szybkie wygrane bezpieczeństwa)
3. **Faza B** (API ticket 2-fazowy) — PRZED launcherem! Bez ticket-gate launcher daje tylko złudzenie bezpieczeństwa
4. **Faza C** (serwer ticket) — zamknięcie od strony serwera
5. **Faza E** (launcher) — gracz przyzwyczaja się do nowego flow, launch-token jako dodatkowa warstwa
6. **Faza D** (feature flags) — dopiero gdy tryby działają end-to-end

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
*Źródło: zarys_planu_modyfikacji_klienta.md + analiza kodu + review ChatGPT ×3 + review Codex ×4*  
*Następny krok: implementacja Fazy A (klient UX) → Faza E (launcher)*
