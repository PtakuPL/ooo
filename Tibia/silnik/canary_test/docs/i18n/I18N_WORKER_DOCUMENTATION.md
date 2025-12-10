# I18N Autonomous Worker - Dokumentacja Projektu

## 📋 Przegląd

**i18n_autonomous_worker.sh** to autonomiczny skrypt Bash do automatycznej migracji plików Lua serwera Canary do systemu wielojęzycznego (i18n). Worker działa w tle, przetwarzając pliki NPC i skrypty, wyodrębniając teksty do JSON i zastępując je wywołaniami API i18n.

---

## 🏗️ Architektura

```
┌─────────────────────────────────────────────────────────────┐
│                   i18n_autonomous_worker.sh                  │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ Ekstrakcja  │ -> │  Migracja   │ -> │    JSON     │     │
│  │  stringów   │    │   kodu Lua  │    │   i18n/en/  │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│         │                  │                  │             │
│         v                  v                  v             │
│  ┌─────────────────────────────────────────────────┐       │
│  │              Status & Monitoring                │       │
│  │          i18n/status/*.json                     │       │
│  └─────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Poprawne API i18n

### Dla plików NPC

Worker używa biblioteki **`NPC_LIB.i18n`** z pliku `data-otservbr-global/lib/npc/i18n.lua`:

```lua
-- PRZED (oryginalny kod)
npcHandler:say("Hello, traveler!", npc, creature)

-- PO MIGRACJI (prawidłowe API)
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.npc_name.say_1")
```

#### Dostępne funkcje NPC_LIB.i18n:

| Funkcja | Opis |
|---------|------|
| `NPC_LIB.i18n.npcSay(npcHandler, npc, creature, key, args)` | Pojedyncza wypowiedź NPC |
| `NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, keys, delay)` | Wiele wypowiedzi z opóźnieniem |
| `NPC_LIB.i18n.setLocalizedGreet(npcHandler, key)` | Powitanie NPC |
| `NPC_LIB.i18n.setLocalizedFarewell(npcHandler, key)` | Pożegnanie NPC |
| `NPC_LIB.i18n.setLocalizedWalkaway(npcHandler, key)` | Gdy gracz odchodzi |

### Dla skryptów Lua

```lua
-- PRZED
player:sendTextMessage(MESSAGE_INFO_DESCR, "You found a treasure!")

-- PO MIGRACJI
player:sendLocalizedTextMessage(MESSAGE_INFO_DESCR, "scripts.treasure_found")
```

### Dla systemu serwera

```lua
-- Funkcja t() z data/libs/server_i18n.lua
local text = t("server.welcome_message", {name = player:getName()}, player)
```

---

## 📁 Struktura plików

```
canary_test/
├── i18n_autonomous_worker.sh      # Główny skrypt workera
├── i18n_worker.log                # Log działania
├── .worker.pid                    # PID procesu
├── i18n_worker_state.json         # Stan workera
├── i18n_processed_files.txt       # Lista przetworzonych plików
├── i18n_excluded_files.txt        # Pliki wykluczone z migracji
│
├── i18n/
│   ├── en/                        # Klucze angielskie (źródłowe)
│   │   ├── npc.json              # Klucze NPC
│   │   ├── scripts.json          # Klucze skryptów
│   │   ├── items.json            # Przedmioty
│   │   ├── monsters.json         # Potwory
│   │   └── ...
│   ├── pl/                        # Tłumaczenia polskie
│   ├── es/, de/, pt/, ...         # Pozostałe języki (53 total)
│   └── status/
│       ├── npc.json              # Status kategorii NPC
│       ├── scripts.json          # Status skryptów
│       └── activity.json         # Aktywność workera
│
└── data-otservbr-global/
    ├── lib/npc/i18n.lua          # Biblioteka NPC i18n (NIE MODYFIKOWAĆ)
    └── npc/                       # Pliki NPC do migracji
        ├── alyxo.lua
        ├── alesar.lua
        └── ...
```

---

## 🔄 Wzorce migracji

### Wzorzec 1: Pojedyncza wypowiedź NPC

```lua
-- PRZED:
npcHandler:say("Welcome to my shop!", npc, creature)

-- PO:
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shop_keeper.say_1")

-- JSON (i18n/en/npc.json):
{
  "npc.shop_keeper.say_1": "Welcome to my shop!"
}
```

### Wzorzec 2: Wiele wypowiedzi (tablica jednolinijkowa)

```lua
-- PRZED:
npcHandler:say({"First message.", "Second message."}, npc, creature)

-- PO (każda wypowiedź osobno):
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.npc_name.say_1")
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.npc_name.say_2")

-- JSON:
{
  "npc.npc_name.say_1": "First message.",
  "npc.npc_name.say_2": "Second message."
}
```

### Wzorzec 3: Wieloliniowe tablice (NOWE - 2025-12-09)

Worker potrafi teraz migrować skomplikowane wieloliniowe tablice:

```lua
-- PRZED:
npcHandler:say({
    "This is a very long message that spans...",
    "Multiple lines in the source code...",
    "For better readability.",
}, npc, creature)

-- PO:
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.npc_name.multi_1")
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.npc_name.multi_2")
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.npc_name.multi_3")

-- JSON:
{
  "npc.npc_name.multi_1": "This is a very long message that spans...",
  "npc.npc_name.multi_2": "Multiple lines in the source code...",
  "npc.npc_name.multi_3": "For better readability."
}
```

**Narzędzie:** `tools/migrate_multiline_say.py`

```bash
# Migracja pojedynczego pliku
python3 tools/migrate_multiline_say.py --file data-otservbr-global/npc/example.lua

# Migracja wszystkich NPC
python3 tools/migrate_multiline_say.py

# Migracja z limitem
python3 tools/migrate_multiline_say.py --limit 50
```

### Wzorzec 4: StdModule.say (ręczna migracja)

```lua
-- PRZED:
keywordHandler:addKeyword({"help"}, StdModule.say, {
    npcHandler = npcHandler,
    text = "I can help you with trading."
})

-- PO (wymaga ręcznej migracji - worker tylko ekstrahuje):
-- TODO: Użyj NPC_LIB.i18n.setKeywordLocalized lub ręcznie zmodyfikuj
```

---

## ⚙️ Konfiguracja workera

### Uruchomienie

```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test
./i18n_autonomous_worker.sh &
```

### Zatrzymanie

```bash
pkill -f i18n_autonomous_worker
# lub
kill $(cat .worker.pid)
```

### Monitorowanie

```bash
# Logi na żywo
tail -f i18n_worker.log

# Status
cat i18n/status/npc.json | jq .
```

---

## ⚙️ Tryby, flagi i pliki stanu (Runbook)

- Główne wejście: `i18n_worker_simple.sh` (v2.0).
- Tryb domyślny bez flag: MIGRATION (8 etapów).  
- Tryb ciągły: `./i18n_worker_simple.sh --continuous <batch_size> <sleep_sec>`  
  - Przykład: `./i18n_worker_simple.sh --continuous 10 15` (10 plików na cykl, 15s przerwy).
- Tłumaczenia ręczne (agent wpisuje w terminalu): `./i18n_worker_simple.sh --translate pl`
- Pojedynczy plik: `./i18n_worker_simple.sh --file data-otservbr-global/npc/alexander.lua`
- Aktualizacja dashboardu: `./i18n_worker_simple.sh --update-status`
- Pauza kategorii po pustym batchu: zapisywana w `.i18n_category_state.json` (progressive backoff 5m → 10m → 30m → 1h → 2h).

### Kluczowe pliki stanu
- `.i18n_category_state.json` – backoff per kategoria (npc, scripts, items, monsters itd.).
- `i18n_file_status.json` – status per plik (etapy pipeline).
- `i18n_processed_files.txt` – lista już obrobionych.
- `i18n_excluded_files.txt` – wykluczenia stałe (patrz też `i18n_excluded_files.txt.bak*`).
- `i18n_worker_state.json` – ostatnie uruchomienie, PID, parametry.
- `i18n_worker.log` / `i18n_worker_v5.log` / `work_i18n_*.log` – logi historyczne.

### Szybkie procedury operacyjne
- **Restart workera**: `pkill -f i18n_worker_simple.sh || true && ./i18n_worker_simple.sh --continuous 10 15 &`
- **Odblokowanie kategorii**: usuń wpis z `.i18n_category_state.json` lub usuń plik, by zresetować backoff.
- **Recovery po crashu**: usuń `.worker.pid` jeśli istnieje, sprawdź `i18n_worker.log`, uruchom ponownie w trybie continuous.
- **Kontrola progresu**: `jq '.total_processed' .i18n_category_state.json` oraz `tail -n 20 i18n_worker.log`.

---

## 📊 Statystyki (stan na 09.12.2025 03:05)

| Metryka | Wartość |
|---------|---------|
| Plików NPC z prawidłowym API | 595+ |
| Kluczy w JSON | 11500+ |
| Wieloliniowych tablic zmigrowanych | 2860 |
| Tłumaczeń PL | 372 (ok. 3%) |
| Języków | 53 |

---

## 🛠️ Rozwiązywanie problemów

### Problem: Git lock file

```bash
rm -f /home/ptaku/serweryt/.git/index.lock
```

### Problem: Wiele procesów workera

```bash
pkill -f i18n_autonomous_worker
rm -f .worker.pid
./i18n_autonomous_worker.sh &
```

### Problem: Worker nie pushuje do GitHub

Sprawdź czy `i18n_status_pusher.sh` działa:
```bash
ps aux | grep pusher
bash i18n_status_pusher.sh
```

---

## 📝 Historia zmian

### 2025-12-09 (wieczór)
- ✅ **NOWE:** Pełna obsługa wieloliniowych tablic `npcHandler:say({...})`
- ✅ Dodano narzędzie `tools/migrate_multiline_say.py` 
- ✅ Zmigrowano 2860 stringów z wieloliniowych tablic
- ✅ 228 plików NPC zaktualizowanych
- ✅ Dodano auto-push do GitHub co 2 minuty

### 2025-12-09 (rano)
- ✅ Naprawiono API - zmiana z nieistniejącego `sayLocalized` na `NPC_LIB.i18n.npcSay`
- ✅ Zmigrowano 186 plików NPC z prawidłowym API
- ✅ Naprawiono problem z git lock file
- ✅ Push 270 plików do GitHub

### Wcześniej
- Implementacja autonomicznego workera
- Integracja z pipeline Python dla synchronizacji języków
- System statusów i monitoringu

---

## 🔗 Powiązane pliki

- `data-otservbr-global/lib/npc/i18n.lua` - Biblioteka NPC i18n (źródło prawdy dla API)
- `data/libs/server_i18n.lua` - Funkcja `t()` dla serwera
- `docs/I18N_DEVELOPMENT_ROADMAP.md` - Roadmapa rozwoju
- `I18N_STATUS.md` - Aktualny status tłumaczeń

---

## 👤 Autor

Projekt stworzony we współpracy z GitHub Copilot dla serwera Canary Tibia.

**Repozytorium:** https://github.com/PtakuPL/ooo
