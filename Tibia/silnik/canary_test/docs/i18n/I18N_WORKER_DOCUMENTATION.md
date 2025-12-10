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
- `worker_commands.txt` / `.worker_command` – zdalne sterowanie dispatcherem (FORCE:, RANDOM, STATUS, SKIP, PAUSE:n, NOTE:).
- `i18n_global_stats.json` – licznik cykli i ostatnia aktualizacja dashboardu.

### Szybkie procedury operacyjne
- **Restart workera**: `pkill -f i18n_worker_simple.sh || true && ./i18n_worker_simple.sh --continuous 10 15 &`
- **Odblokowanie kategorii**: usuń wpis z `.i18n_category_state.json` lub usuń plik, by zresetować backoff.
- **Recovery po crashu**: usuń `.worker.pid` jeśli istnieje, sprawdź `i18n_worker.log`, uruchom ponownie w trybie continuous.
- **Kontrola progresu**: `jq '.total_processed' .i18n_category_state.json` oraz `tail -n 20 i18n_worker.log`.

### Tryby i komendy CLI (mapowanie na kod)
- `--file <path>` – MIGRATION dla jednego pliku (8 etapów).
- `--auto [N]` – MIGRATION dla N plików NPC (StdModule.say/text lub npcHandler:say), bez dispatcherów.
- `--continuous [--batch N] [--delay S]` – pełny tryb 24/7 z dispatcherem (MIGRATION → TRANSLATION_SYNC → AUTO_TRANSLATE → IDLE), obsługuje komendy z `worker_commands.txt`.
- `--translate [lang]` – tryb interaktywny tłumaczeń (SKIP/QUIT/SAVE).
- `--status` / `--stats` – dashboard tekstowy (statystyki plików, etapy, klucze).
- `--update-status` – aktualizacja `I18N_STATUS.md` i plików statusu.
- Brak flagi – wyświetla krótką pomoc (opis trybów).

### Dispatcher i kategorie (tryb continuous)
- MIGRATION kategorie: `npc, scripts, monsters, spells, items, raids, world, libs, events, chatchannels, modules, startup, npclib, php, html, cpp, client, sendtextmessage/stm, keywordhandler/kwh, twig`.
- TRANSLATION_SYNC: synchronizacja kluczy EN → język, wykrywa brakujące klucze per plik JSON i język.
- AUTO_TRANSLATE: automatyczne wypełnianie placeholderów (non-interactive) dla brakujących kluczy.
- IDLE: gdy brak pracy (migracja + tłumaczenia zakończone), usypia na 5 minut.
- Sterowanie z plików: `worker_commands.txt` (z repo) lub `.worker_command` (lokalnie) – umożliwia wymuszenie kategorii, losowanie, pauzę, skip cyklu, notatki.

### Git / push
- Każdy cykl continuous: `git add -A` → commit `"📊 I18N: <liczba kluczy> <tryb> - Cykl #<n>"` → `git push origin master` (jeśli są zmiany). Jeśli push padnie, cykl leci dalej.

---

## 🔎 Audyt działania (2025-12-11)

- `i18n_global_stats.json`: 20 cykli, tryb MIGRATION, ~5325 kluczy (npc 5206, scripts 78, monsters 10, startup 8, php 8, cpp 15), 812 plików NPC przetworzonych; ostatnia sesja: 265 kluczy z 89 tablic `npcHandler:say({...})`.
- `I18N_STATUS.md` jest rozjechany (26 plików, 9810 kluczy) – uruchom `--update-status`, by zsynchronizować realne dane.
- Worker commit/pushuje co cykl na `master` – brak ochrony przed kolizją; warto dodać `--no-git` lub pracę na branchu roboczym.
- Brak walidacji Lua po transformacji; ryzyko zepsucia builda (przyda się `lua -p` / `luacheck`).
- Detekcja wzorców (grep) nie łapie konkatenacji/zmiennych – potrzebny parser Lua lub rozszerzone regexy.
- AUTO_TRANSLATE nie pilnuje placeholderów `{var}`/`|TOKEN|`; brak throttlingu i pamięci tłumaczeń.

---

## 🚀 Pomysły na usprawnienia

1) **Walidacja syntaktyczna**: po transformacji `lua -p <plik>`; fail → rollback z backupu i oznaczenie w statusie.  
2) **Bezpieczny git**: flaga `--no-git` + `--branch <name>`; brak push, jeśli w repo są cudze zmiany.  
3) **Lepsza detekcja**: parser Lua/luacheck lub regex na konkatenacje (`"foo" .. var`), by nie gubić stringów.  
4) **Raport “hard strings”**: CSV/MD w `docs/i18n/generated/` po każdym cyklu continuous.  
5) **Ochrona placeholderów**: validator `{}` i `| |` w AUTO_TRANSLATE; blokuj, gdy liczba placeholderów się zmienia.  
6) **Kolejka + TM**: `i18n/translation_queue.json` (lang, key, source, priority) i `translation_memory.json` (hash źródła → tłumaczenie).  
7) **Limit MT**: `--auto-translate-limit N` + throttle/retry z backoffem, by nie zalać repo.  
8) **Smoke-test**: szybki test po batchu (np. `lua -e 'dofile(\"<plik>\")'` lub istniejący validator).  
9) **Status sync**: `--update-status` ma brać liczby z `i18n/en/*.json` i `i18n_global_stats.json`, by uniknąć rozjazdów.  
10) **Tryb tylko tłumaczeń**: `--translations-only` odcina migrację przy code-freeze.  

---

## 🌐 Plan tłumaczeń na wszystkie języki (53+)

**Źródło:** EN. **Cel:** 53 języki + łatwe dodanie nowych. **Priorytet:** EU → LATAM → APAC.

### Etap A: Synchronizacja
- `TRANSLATION_SYNC` generuje `i18n/status/translation_backlog.json` (per lang, per plik).
- Validator placeholderów `{var}` / `|TOKEN|` przed włożeniem do kolejki.

### Etap B: Kolejka
- `i18n/translation_queue.json`: `lang`, `key`, `source`, `context`, `priority`.  
- Priorytety: npc > quests/scripts > system; nowe klucze (<24h) na górze.  
- Batch 100 kluczy/lang, retry z backoffem.

### Etap C: Źródła tłumaczeń
- 1) TM (`translation_memory.json` z hashem źródła).  
- 2) MT (lokalny model/API) z walidacją placeholderów i długości.  
- 3) Fallback EN z tagiem `[EN]`, gdy brak tłumaczenia.

### Etap D: Walidacja jakości
- Placeholdery bez zmian, brak podwójnych spacji, limit długości (np. 1.5× EN dla UI).  
- Reguły językowe: nie tłumacz komend (‘yes/no/trade’), zostaw `|...|`.  
- Audyt: z każdego batcha 100 kluczy ręcznie sprawdź 5.

### Etap E: Zapis i raport
- Zapis do `i18n/<lang>/*.json`, aktualizacja `i18n_global_stats.json`, raport `docs/i18n/generated/translation_report_<data>.md`.  
- `--update-status` odświeża `I18N_STATUS.md` na realnych danych.

### Etap F: Pamięć tłumaczeń
- Po każdym batchu dopisz do `translation_memory.json` (hash źródła → tłumaczenie) dla spójności i reuse.

---

## ❓ FAQ (operacyjne)
- **Worker wisi?** Sprawdź `.worker_simple.pid`, `ps aux | grep i18n_worker_simple`, usuń PID i odpal `--continuous`.  
- **Znikły tłumaczenia?** Sprawdź `translation_queue.json`/TM; wymuś `TRANSLATION_SYNC` (continuous zrobi to w IDLE).  
- **Git koliduje z moimi zmianami?** Uruchom z `--no-git` (po wdrożeniu) lub `git stash push` przed startem.  
- **Wymuszenie kategorii?** W `worker_commands.txt` dodaj `FORCE:npc` (bez #); worker zaczyta w kolejnym cyklu.  

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
