# 🔧 I18N Worker - Plan Pełnej Migracji

> **Dokument**: Plan rozbudowy workera o pełną migrację plików  
> **Wersja**: 1.0  
> **Data**: 2025-12-10  
> **Status**: W TRAKCIE IMPLEMENTACJI

---

## 📋 Kontekst

Worker `i18n_autonomous_worker.sh` obecnie **tylko ekstrahuje** teksty do JSON, ale **NIE ZAMIENIA** hardcoded tekstów w plikach źródłowych na wywołania i18n.

### Obecny stan (PRZED):
```lua
-- Plik: oldrak.lua
npcHandler:say("Welcome to my temple!", npc, creature)
StdModule.say, { text = "My name is Oldrak." }
player:sendTextMessage(MESSAGE_INFO_DESCR, "You found a treasure!")
```

### Cel (PO migracji):
```lua
-- Plik: oldrak.lua  
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.greet")
-- StdModule.say wymaga specjalnej obsługi (patrz sekcja 3)
player:sendLocalizedTextMessage(MESSAGE_INFO_DESCR, "quests.treasure_found")
```

---

## 📊 Statystyki do migracji

| Wzorzec | Plików | Status | Metoda migracji |
|---------|--------|--------|-----------------|
| `NPC_LIB.i18n.npcSay` | 446 | ✅ Zmigrowane | - |
| `sendLocalizedTextMessage` | 26 | ✅ Zmigrowane | - |
| `setLocalizedMessage` | 1 | ✅ Zmigrowane | - |
| **`npcHandler:say(`** | 133 | ❌ Do migracji | → `NPC_LIB.i18n.npcSay()` |
| **`StdModule.say`** | 297 | ❌ Do migracji | → Specjalna obsługa |
| **`sendTextMessage`** | 449 | ❌ Do migracji | → `sendLocalizedTextMessage()` |

**RAZEM do migracji: ~879 wystąpień w plikach**

---

## 🎯 Wzorce Migracji

### 1. `npcHandler:say()` → `NPC_LIB.i18n.npcSay()`

**PRZED:**
```lua
npcHandler:say("Welcome, traveler!", npc, creature)
npcHandler:say("Goodbye!", npc, creature)
```

**PO:**
```lua
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.{npc_name}.greet")
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.{npc_name}.farewell")
```

**Regex wykrywania:**
```regex
npcHandler:say\s*\(\s*"([^"]+)"\s*,\s*npc\s*,\s*creature\s*\)
```

---

### 2. `player:sendTextMessage()` → `player:sendLocalizedTextMessage()`

**PRZED:**
```lua
player:sendTextMessage(MESSAGE_INFO_DESCR, "You have found a secret passage!")
player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Quest completed!")
```

**PO:**
```lua
player:sendLocalizedTextMessage(MESSAGE_INFO_DESCR, "quests.secret_passage")
player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.completed")
```

**Regex wykrywania:**
```regex
player:sendTextMessage\s*\(\s*(MESSAGE_[A-Z_]+)\s*,\s*"([^"]+)"\s*\)
```

**Kategorie kluczy:**
- `MESSAGE_INFO_DESCR` → `system.*` lub `quests.*`
- `MESSAGE_EVENT_ADVANCE` → `quests.*` lub `player.*`
- `MESSAGE_STATUS_CONSOLE_BLUE` → `system.*`
- `MESSAGE_DAMAGE_*` → `combat.*`

---

### 3. `StdModule.say` → Specjalna obsługa ⚠️

**Problem:** `StdModule.say` jest częścią biblioteki `npclib` i wymaga modyfikacji samego modułu lub zamiany na inne podejście.

**PRZED:**
```lua
keywordHandler:addKeyword({ "job" }, StdModule.say, { 
    npcHandler = npcHandler, 
    text = "I guard this temple." 
})
```

**Opcje migracji:**

#### Opcja A: Modyfikacja StdModule (zalecana)
Dodać do `StdModule.say` obsługę klucza i18n:
```lua
keywordHandler:addKeyword({ "job" }, StdModule.say, { 
    npcHandler = npcHandler, 
    i18nKey = "npc.oldrak.job"  -- nowy parametr
})
```

#### Opcja B: Zamiana na callback
```lua
keywordHandler:addKeyword({ "job" }, function(npc, creature, message)
    NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.job")
end)
```

#### Opcja C: Wrapper StdModule.i18nSay
Stworzyć nowy moduł `StdModule.i18nSay`:
```lua
keywordHandler:addKeyword({ "job" }, StdModule.i18nSay, { 
    npcHandler = npcHandler, 
    key = "npc.oldrak.job" 
})
```

**Rekomendacja:** Opcja A lub C - minimalna zmiana w plikach NPC.

---

### 4. `npcHandler:setMessage()` → `NPC_LIB.i18n.setLocalizedMessage()`

**PRZED:**
```lua
npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_FAREWELL, "Goodbye!")
```

**PO:**
```lua
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.{name}.greet")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.{name}.farewell")
```

---

### 5. Tablice tekstów (multi-line)

**PRZED:**
```lua
npcHandler:say({
    "First line of dialog...",
    "Second line continues...",
    "And the third line."
}, npc, creature, 300)
```

**PO:**
```lua
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.{name}.multi_1")
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.{name}.multi_2")
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.{name}.multi_3")
```

Lub z sekwencją:
```lua
NPC_LIB.i18n.npcSaySequence(npcHandler, npc, creature, {
    "npc.{name}.multi_1",
    "npc.{name}.multi_2", 
    "npc.{name}.multi_3"
}, 300)
```

---

## 🔄 Plan Implementacji w Workerze

### Faza 1: Ekstrakcja (OBECNA - DZIAŁA ✅)
- [x] Skanowanie plików Lua
- [x] Wykrywanie wzorców tekstowych
- [x] Zapisywanie kluczy do `i18n/en/*.json`
- [x] Oznaczanie plików jako przetworzonych

### Faza 2: Transformacja kodu (DO DODANIA ❌)

#### 2.1 Funkcja `transform_npcHandler_say()`
```bash
# Zamienia: npcHandler:say("text", npc, creature)
# Na:       NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "klucz")
```

#### 2.2 Funkcja `transform_sendTextMessage()`
```bash
# Zamienia: player:sendTextMessage(TYPE, "text")
# Na:       player:sendLocalizedTextMessage(TYPE, "klucz")
```

#### 2.3 Funkcja `transform_setMessage()`
```bash
# Zamienia: npcHandler:setMessage(TYPE, "text")
# Na:       NPC_LIB.i18n.setLocalizedMessage(npcHandler, TYPE, "klucz")
```

#### 2.4 Funkcja `transform_StdModule_say()` (OPCJONALNIE)
```bash
# Zależy od wybranej strategii (A/B/C)
```

### Faza 3: Walidacja
- [ ] Sprawdzenie składni Lua po transformacji
- [ ] Test czy serwer się kompiluje
- [ ] Rollback w przypadku błędów

---

## 📁 Struktura Kluczy JSON

```
i18n/en/
├── npc.json           # Dialogi NPC
│   ├── npc.{name}.greet
│   ├── npc.{name}.farewell
│   ├── npc.{name}.busy
│   ├── npc.{name}.dialog.{keyword}
│   ├── npc.{name}.quest.{step}
│   └── npc.{name}.multi_{n}
│
├── quests.json        # Komunikaty questowe
│   ├── quests.{quest_name}.{step}
│   └── quests.{quest_name}.complete
│
├── system.json        # Wiadomości systemowe
│   ├── system.error.*
│   ├── system.info.*
│   └── system.warning.*
│
├── player.json        # Komunikaty gracza
│   ├── player.login.*
│   ├── player.level.*
│   └── player.death.*
│
└── game.json          # Mechaniki gry
    ├── game.loot.*
    ├── game.combat.*
    └── game.trade.*
```

---

## ⚡ Priorytety Migracji

1. **WYSOKI**: `npcHandler:say()` - 133 plików, łatwa zamiana
2. **WYSOKI**: `sendTextMessage` w questach - kluczowe dla graczy
3. **ŚREDNI**: `StdModule.say` - 297 plików, wymaga decyzji o strategii
4. **NISKI**: Voices NPC - statyczne, rzadko widoczne

---

## 🛠️ Następne Kroki

1. [x] **Decyzja**: Wybór strategii dla `StdModule.say` → **Opcja A** (i18nKey)
2. [x] **Implementacja**: Dodanie `transform_*` funkcji do workera
3. [x] **Test**: Migracja jednego pliku NPC jako proof-of-concept
4. [x] **Walidacja**: Sprawdzenie czy serwer działa po migracji
5. [x] **Masowa migracja**: Uruchomienie workera (tryb ciągły)

### Sugestie operacyjne (dla agenta)
- Dodaj do `StdModule.say` obsługę parametru `i18nKey` (jeśli jeszcze nie na wszystkich maszynach) i preferuj Opcję A/C – zmniejszy to liczbę zmian w plikach NPC.
- W workerze dołóż walidację syntaktyczną Lua po transformacji (np. `luacheck` lub szybki `lua -p <plik>`), zanim batch trafi do git.
- Przed masową migracją stwórz krótką listę kanałów powiadomień (log + plik `i18n/status/activity.json`) z wynikiem każdego cyklu, żeby agent wiedział czy batch przeszedł.
- Przy transformacji `sendTextMessage` grupuj klucze w kategoriach (`quests.*`, `system.*`, `combat.*`) – ułatwi tłumaczenia i kontrolę jakości.
- Dodaj mały smoke test: uruchomienie `./canary-debug --validate-i18n` (lub istniejący odpowiednik) na zestawie zmigrowanych plików, aby złapać brakujące klucze zanim pójdą tłumaczenia.
- Utrzymuj świeży raport “hard strings” i “translation backlog”: dwa pliki CSV/MD generowane co cykl continuous (lista nowych literalnych tekstów + lista braków tłumaczeń per język).
- Dodaj tryb `--translations-only` i ogranicz auto-translate batch (`--auto-translate-limit`) żeby nie blokować migracji, gdy kod jest zamrożony.

---

## 📝 Notatki

- Biblioteka `NPC_LIB.i18n` już istnieje w `data-otservbr-global/lib/npc/i18n.lua`
- Helper `player:sendLocalizedTextMessage()` już działa (bindings w C++)
- 446 plików NPC już używa `NPC_LIB.i18n.npcSay` - można użyć jako wzór
- Worker musi zachować kompatybilność wsteczną (nie psuć działających plików)

---

## 📚 Powiązane dokumenty

- `docs/i18n/I18N_WORKER_DOCUMENTATION.md` - dokumentacja workera
- `docs/i18n/NPC_MIGRATION_STATUS.md` - status migracji NPC
- `docs/I18N_DEVELOPMENT_ROADMAP.md` - ogólny plan rozwoju
- `data-otservbr-global/lib/npc/i18n.lua` - biblioteka i18n dla NPC

---

## 📊 Status Sugestii Operacyjnych (2025-12-11)

**🎉 WSZYSTKIE ZAIMPLEMENTOWANE!**

| Sugestia | Status | Implementacja |
|----------|--------|---------------|
| `StdModule.say` + `i18nKey` | ✅ | Worker dodaje `i18nKey=` do parametrów |
| Walidacja `lua -p` | ✅ | `validate_lua_file()` w workerze |
| Smoke-test `loadfile()` | ✅ | `smoke_test_lua()` w workerze |
| Raport "hard strings" | ✅ | `tools/hard_strings_report.py` → 24204 wpisów |
| Translation queue | ✅ | `tools/build_translation_queue.py` → 53884 wpisów |
| `--translations-only` | ✅ | Pomija MIGRATION, tylko tłumaczenia |
| `--translate-limit N` | ✅ | Limit kluczy na cykl |
| `--no-git` | ✅ | Wyłącza git add/commit/push |
| Translation Memory | ✅ | `translation_memory.json` z hash src |
| Placeholder guard | ✅ | Walidacja `{}` i `|...|` w tłumaczeniach |

*Ostatnia aktualizacja: 2025-12-11 ~04:15 przez Agent 2*
