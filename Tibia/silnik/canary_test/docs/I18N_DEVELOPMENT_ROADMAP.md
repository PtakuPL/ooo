# 🗺️ I18N System - Plan Rozwoju i Usprawnień

> **Dokument**: Plan rozwoju systemu internacjonalizacji  
> **Wersja**: 2.1  
> **Data**: 2025-12-10  
> **Autor**: AI Assistant + PtakuPL

---

## 🐛 KNOWN ISSUES / DO NAPRAWY

### 🔴 Priorytet WYSOKI

| # | Problem | Opis | Status |
|---|---------|------|--------|
| 1 | **Tryb TRANSLATION pomijany w background** | Worker po zakończeniu migracji przechodzi do TRANSLATION, ale wymaga interaktywnego terminala i jest pomijany. Powinien automatycznie tłumaczyć klucze EN→PL bez interakcji użytkownika. | ❌ DO NAPRAWY |
| 2 | **Brak automatycznego przejścia do dokumentacji** | Po migracji worker nie generuje automatycznie dokumentacji dla wszystkich plików - tylko dla tych przetwarzanych w danym cyklu. | ❌ DO NAPRAWY |
| 3 | **Pliki z konkatenacjami pomijane bez logu** | Pliki z `npcHandler:say("text" .. var)` są pomijane bez informacji dlaczego. | ⚠️ CZĘŚCIOWO |

### 🟡 Priorytet ŚREDNI

| # | Problem | Opis | Status |
|---|---------|------|--------|
| 4 | **npcHandler:say z tablicami** | `npcHandler:say({...})` z tablicami tekstów nie jest obsługiwane. | ❌ DO ROZBUDOWY |
| 5 | **voices pattern** | `voices = {{ text = "..." }}` wymaga modyfikacji C++ (broadcast → per-player). | ❌ WYMAGA C++ |
| 6 | **Brak raportu końcowego** | Po zakończeniu migracji brak szczegółowego raportu co zostało zrobione vs co pominięto. | ❌ DO DODANIA |

### ✅ NAPRAWIONE (2025-12-10)

| # | Problem | Rozwiązanie |
|---|---------|-------------|
| N1 | **Bug stage_5 kasujący JSON** | Zmieniono `except: data = {}` na `exit(1)` przy błędzie odczytu |
| N2 | **addGreetKeyword/addFarewellKeyword** | Dodano transformację + naprawiono regex dla callbacków |
| N3 | **GreetModule bez i18n** | Dodano obsługę i18nKey w `custom_modules.lua` |

### 🟢 Priorytet NISKI

| # | Problem | Opis | Status |
|---|---------|------|--------|
| 7 | **Zombie procesy** | Stare procesy workera pozostają jako `<defunct>`. | ⚠️ KOSMETYCZNE |
| 8 | **Duplikaty kluczy w JSON** | Brak sprawdzania czy klucz już istnieje z inną wartością. | ❌ DO WALIDACJI |

---

## 🔧 PLAN NAPRAWY (Krótkoterminowy)

### Issue #1: Tryb TRANSLATION w background

**Problem**: Tryb TRANSLATION wymaga interaktywnego terminala (`read` do potwierdzenia tłumaczeń).

**Rozwiązanie**: 
1. Stworzyć tryb `TRANSLATION_AUTO` który automatycznie tłumaczy bez potwierdzenia
2. Użyć API tłumaczeniowego (Google/DeepL) w tle
3. Lub: Kopiować wartości EN jako placeholder z prefiksem `[AUTO] `

**Implementacja**:
```bash
# W select_work_mode po MIGRATION:
if needs_migration == 0:
    # Przejdź do automatycznego tłumaczenia
    print("TRANSLATION_AUTO:pl:1000")
```

### Issue #2: Automatyczna dokumentacja

**Problem**: Dokumentacja generowana tylko dla przetwarzanych plików.

**Rozwiązanie**:
1. Dodać nowy tryb `DOCUMENTATION` po MIGRATION
2. Skanować wszystkie pliki z i18nKey i generować MD
3. Aktualizować index dokumentacji

---

## 🎯 ANALIZA TECHNICZNA: voices i keywordHandler

### 📢 npcConfig.voices - Analiza (2025-12-10)

**Lokalizacja w kodzie:**
- Definicja w NPC: `npcConfig.voices = { interval=N, chance=N, { text = "...", yell = true/false }, ... }`
- Przetwarzanie Lua: `data/scripts/lib/register_npc_type.lua` → `registerNpcType.voices()`
- Przetwarzanie C++: `src/lua/functions/creatures/npc/npc_type_functions.cpp` → `luaNpcTypeAddVoice()`
- Odtwarzanie C++: `src/creatures/npcs/npc.cpp` linii 635-644 → `g_game().internalCreatureSay()`

**Problem i18n voices:**
Voices są **broadcastem** do wszystkich graczy w zasięgu NPC przez `g_game().internalCreatureSay()`. 
Tekst jest wysyłany jednocześnie do wielu graczy - a każdy może mieć inny język!

**Obecny przepływ:**
```
1. Lua: npcConfig.voices = {{ text = "Hello!", yell = false }}
2. Lua: registerNpcType.voices() → npcType:addVoice(text, interval, chance, yell)
3. C++: luaNpcTypeAddVoice() → voiceBlock_t{text, yellText} → voiceVector.push_back()
4. C++: npc.cpp onThink() → losowy voice → g_game().internalCreatureSay(text)
5. C++: game.cpp → dla każdego spectator → player->sendCreatureSay(text)
```

**Propozycja rozwiązania (WYMAGA C++):**

1. **Rozszerzyć `voiceBlock_t`** o pole `std::string i18nKey`:
   ```cpp
   struct voiceBlock_t {
       std::string text;      // Oryginalna wartość (fallback)
       bool yellText;
       std::string i18nKey;   // NOWE: klucz i18n
   };
   ```

2. **Zmodyfikować `luaNpcTypeAddVoice`** aby przyjmować opcjonalny `i18nKey`:
   ```cpp
   // npcType:addVoice(sentence, interval, chance, yell, i18nKey)
   voice.i18nKey = Lua::isString(L, 6) ? Lua::getString(L, 6) : "";
   ```

3. **Zmodyfikować `npc.cpp`** aby wysyłać zlokalizowany tekst:
   ```cpp
   for (const auto &spectator : spectators) {
       if (const auto &tmpPlayer = spectator->getPlayer()) {
           std::string localizedText = text;
           if (!i18nKey.empty()) {
               localizedText = tmpPlayer->getLocalizedText(i18nKey, text);
           }
           tmpPlayer->sendCreatureSay(creature, type, localizedText, pos);
       }
   }
   ```

4. **Zmodyfikować `registerNpcType.voices`** w Lua:
   ```lua
   registerNpcType.voices = function(npcType, mask)
       if type(mask.voices) == "table" then
           local interval = mask.voices.interval
           local chance = mask.voices.chance
           for k, v in pairs(mask.voices) do
               if type(v) == "table" then
                   npcType:addVoice(v.text, interval, chance, v.yell, v.i18nKey or "")
               end
           end
       end
   end
   ```

**Transformacja worker'em:**
```lua
-- PRZED:
npcConfig.voices = {
    interval = 15000, chance = 50,
    { text = "Don't forget to deposit your money!", yell = false },
}

-- PO:
npcConfig.voices = {
    interval = 15000, chance = 50,
    { text = "Don't forget to deposit your money!", yell = false, i18nKey = "npc.paulie.voice_1" },
}
```

**Klucze w npc.json:**
```json
{
    "npc.paulie.voice_1": "Don't forget to deposit your money!"
}
```

**Szacowany nakład pracy:**
- Modyfikacje C++: 2-4 godziny (voiceBlock_t, npc_type_functions, npc.cpp)
- Modyfikacje Lua: 30 min (register_npc_type.lua)
- Transformacja worker: 1-2 godziny (nowy etap stage_4_voices)
- Testowanie: 1-2 godziny

### 🔑 keywordHandler:add*Keyword - Analiza (TODO)

**Typy:**
- `keywordHandler:addKeyword({"word"}, callback, {i18nKey = "..."})`
- `keywordHandler:addAliasKeyword({"alias"}, callback)`

**Lokalizacja:**
- Definicja: `data/npclib/npc_system/keyword_handler.lua`

**Status:** ❌ Wymaga analizy

---

## 📋 Spis treści

1. [Obecny stan systemu](#-obecny-stan-systemu)
2. [Faza 1: Optymalizacja Workera](#-faza-1-optymalizacja-workera)
3. [Faza 2: Rozszerzenie typów plików](#-faza-2-rozszerzenie-typów-plików)
4. [Faza 3: System tłumaczeń](#-faza-3-system-tłumaczeń)
5. [Faza 4: Walidacja i testy](#-faza-4-walidacja-i-testy)
6. [Faza 5: Integracja z serwerem](#-faza-5-integracja-z-serwerem)
7. [Faza 6: Panel administracyjny](#-faza-6-panel-administracyjny)
8. [Faza 7: Automatyzacja CI/CD](#-faza-7-automatyzacja-cicd)
9. [Skrypty do stworzenia](#-skrypty-do-stworzenia)
10. [Priorytety i harmonogram](#-priorytety-i-harmonogram)

---

## 📊 Obecny stan systemu

> **Ostatnia aktualizacja:** 2025-12-10 14:15 UTC

### ✅ Co mamy (ZROBIONE):
- ✅ `i18n_worker_simple.sh` - Worker v2.2 Multi-Mode (8 etapów)
- ✅ `i18n_guardian.sh` - Guardian restartujący workera + auto-push
- ✅ 53 katalogi językowe w `i18n/`
- ✅ Pliki JSON z kluczami (npc.json, items.json, scripts.json, etc.)
- ✅ Cron job dla Guardian
- ✅ **StdModule.say** - 297/297 plików zmigrowanych (100%)
- ✅ **npcHandler:say("...", npc, creature)** - ~150 plików zmigrowanych
- ✅ **addGreetKeyword/addFarewellKeyword** - 43/43 plików zmigrowanych (78 kluczy)
- ✅ **GreetModule** obsługuje i18nKey w `custom_modules.lua`
- ✅ **4252 kluczy** w `i18n/en/npc.json`

### ⚠️ NAPRAWIONE BUGI (ta sesja):
- ✅ **Krytyczny bug stage_5**: `data = {}` przy błędzie kasowało JSON → zmieniono na `exit(1)`
- ✅ **Regex greet/farewell**: Nie łapał formatu z callbackiem `}, function(player)` → naprawiono

### ❌ Pozostało do zrobienia:
- ❌ **voices** - ~300+ plików, wymaga modyfikacji C++ (broadcast → per-player)
- ❌ **npcHandler:say({...})** - tablice tekstów (~50 plików)
- ❌ **Automatyczne tłumaczenia** - tryb TRANSLATION wymaga interaktywnego terminala
- ✅ **StdModule.say** - 297/297 plików zmigrowanych ✅
- ✅ **npcHandler:say("text")** - ~450 plików z NPC_LIB.i18n.npcSay ✅
- ✅ **~4200 kluczy** wyciągniętych do en/npc.json
- ✅ Placeholder'y dla 8 języków (pl, de, es, fr, it, pt, ru, uk)
- ✅ Dokumentacja MD dla każdego NPC
- ✅ Live Dashboard na GitHub (I18N_STATUS.md)

### 🆕 Nowe w v2.1 (2025-12-10):
- ✅ Transformacja `npcHandler:say("text", npc, creature)` → `NPC_LIB.i18n.npcSay()`
- ✅ Obsługa multi-line tekstów (teksty rozciągnięte na wiele linii)
- ✅ Rozróżnianie konkatenacji Lua (` .. `) od wielokropków (`...`)
- ✅ Pomijanie tablic `npcHandler:say({...})` (zachowane bez zmian)
- ✅ Ekstrakcja kluczy z obu wzorców do npc.json

### 🔴 Kolejne do zrobienia (PRIORYTET):
| Wzorzec | Plików | Wymaga C++ | Złożoność | Status |
|---------|--------|------------|-----------|--------|
| `voices = {{ text = }}` | ~131 | **TAK** | 🔶 ŚREDNIA | 📋 ANALIZA GOTOWA |
| `keywordHandler:add*Keyword` | ~21 | NIE | 🟢 NISKA | ❌ DO ANALIZY |
| `npcHandler:say({array})` | ~50 | NIE | 🟢 NISKA | ❌ DO ZROBIENIA |
| `player:sendTextMessage()` | ~312 | NIE | 🟡 ŚREDNIA | ❌ DO ZROBIENIA |

---

## 📈 PEŁNA ANALIZA PROJEKTU (2025-12-10)

### 🎮 1. DATA-OTSERVBR-GLOBAL (Serwer Lua)

| Katalog | Plików | Z tekstami | Status |
|---------|--------|------------|--------|
| **npc/** | 1026 | 812 | 🔄 Częściowo |
| **scripts/** | 1755 | 668 | ❌ Do zrobienia |
| **monster/** | 1637 | 3 | ❌ Do zrobienia |
| **startup/** | 20 | 3 | ❌ Do zrobienia |
| **lib/** | 26 | 10 | ❌ Do zrobienia |
| **migrations/** | 52 | 0 | ✅ Nie wymaga |

#### Typy funkcji tekstowych w NPC:

| Typ | Plików | Z i18nKey | Do migracji | Priorytet | Status |
|-----|--------|-----------|-------------|-----------|--------|
| `StdModule.say(text=)` | 297 | 297 ✅ | 0 | - | ✅ DONE |
| `npcHandler:say("text")` | ~450 | ~450 ✅ | **~2** | - | ✅ v2.1 DONE |
| `npcHandler:say({array})` | ~50 | 0 | **~50** | 🟡 ŚREDNI | ❌ TODO |
| `player:sendTextMessage()` | 312 | 0 | **312** | 🔴 WYSOKI | ❌ TODO |
| `voices = {{ text = }}` | 131 | 0 | **131** | 🟡 ŚREDNI | ❌ TODO (C++) |
| `keywordHandler:add*Keyword` | 21 | 0 | **21** | 🟡 ŚREDNI | ❌ TODO |

### 🌐 2. HTML_COPY (Strona WWW - AAC)

| Typ pliku | Ilość | Z tekstami | Status |
|-----------|-------|------------|--------|
| **PHP** | 5587 | ~1310 | ❌ Do zrobienia |
| **HTML** | 102 | ~50 | ❌ Do zrobienia |
| **JavaScript** | 4967 | ~500 | ❌ Do zrobienia |
| **Twig templates** | 575 | ~300 | ❌ Do zrobienia |

### 📂 3. DATA (Główne skrypty)

| Katalog | Plików | Z tekstami | Status |
|---------|--------|------------|--------|
| **scripts/** | 479 | 200 | ❌ Do zrobienia |
| **libs/** | 55 | 23 | ❌ Do zrobienia |
| **modules/** | 7 | 5 | ❌ Do zrobienia |
| **chatchannels/** | 8 | 6 | ❌ Do zrobienia |
| **npclib/** | 7 | 6 | ❌ Do zrobienia |
| **events/** | 4 | 1 | ❌ Do zrobienia |

### ⚙️ 4. SRC (C++ Server)

| Typ | Ilość | Z stringami | Status |
|-----|-------|-------------|--------|
| **cpp** | 186 | 168 | ❌ Do zrobienia |
| **hpp** | 249 | ~50 | ❌ Do zrobienia |

### 🎮 5. DATA-CANARY

| Katalog | Plików | Z tekstami | Status |
|---------|--------|------------|--------|
| **monster/** | 67 | 51 | ❌ Do zrobienia |
| **scripts/** | 25 | 5 | ❌ Do zrobienia |
| **npc/** | 1 | 1 | ❌ Do zrobienia |

### 💻 6. TESTYY (Instalka/Klient OTClient)

| Typ | Ilość | Z tekstami | Status |
|-----|-------|------------|--------|
| **Lua/OTUI/OTMOD** | 449 | 284 | ❌ Do zrobienia |

---

## 📋 PLAN ROZSZERZENIA WORKERA

### Faza A: NPC Completion (PRIORYTET 🔴)

1. **`npcHandler:say("text")`** - 91 plików
   - Format: `npcHandler:say("text", npc, creature)`
   - Zamiana na: `npcHandler:sayI18n("key", npc, creature)`
   - Klucze: `npc.{nazwa}.say_{N}`

2. **`player:sendTextMessage()`** - 312 plików
   - Format: `player:sendTextMessage(TYPE, "text")`
   - Zamiana na: `player:sendTextMessageI18n(TYPE, "key")`
   - Klucze: `system.{nazwa}.msg_{N}`

### Faza B: Scripts (PRIORYTET 🟡)

3. **data-otservbr-global/scripts/** - 668 plików
   - `player:sendTextMessage()`
   - `creature:say()`
   - `Game.broadcastMessage()`
   - Klucze: `scripts.{kategoria}.{nazwa}.msg_{N}`

### Faza C: C++ Server (PRIORYTET 🟡)

4. **src/*.cpp** - 168 plików
   - `player->sendTextMessage()`
   - `fmt::format()`
   - Wymaga: Raportu + ręcznej implementacji
   - Klucze: `cpp.{moduł}.{funkcja}.msg_{N}`

### Faza D: Website AAC (PRIORYTET 🟢)

5. **html_copy/*.php** - 1310 plików
   - `echo "text"`
   - `$lang['key']`
   - Klucze: `web.{strona}.{sekcja}.msg_{N}`

6. **html_copy/*.twig** - 575 plików
   - `{{ 'text' }}`
   - Klucze: `web.tpl.{nazwa}.msg_{N}`

### Faza E: Klient OTClient (PRIORYTET 🟢)

7. **testyy/** - 284 plików
   - `tr("text")` (już może istnieć system!)
   - `.otui` files
   - Klucze: `client.{moduł}.{element}`

---

## 📊 PODSUMOWANIE DO MIGRACJI

| Kategoria | Plików | Szacunkowa ilość tekstów | Priorytet |
|-----------|--------|--------------------------|-----------|
| NPC (pozostałe) | 403 | ~2000 | 🔴 WYSOKI |
| Scripts Lua | 868 | ~3000 | 🟡 ŚREDNI |
| C++ Server | 218 | ~500 | 🟡 ŚREDNI |
| PHP Website | 1310 | ~5000 | 🟢 NISKI |
| Twig Templates | 575 | ~1500 | 🟢 NISKI |
| OTClient | 284 | ~1000 | 🟢 NISKI |
| **RAZEM** | **~3658** | **~13000** | - |

---

### Ograniczenia obecnego systemu (v2.1):
- ✅ ~~Worker przetwarza tylko `StdModule.say`~~ - NAPRAWIONE v2.1
- ✅ ~~Brak obsługi `npcHandler:say()`~~ - DODANE v2.1
- ❌ Brak obsługi `npcHandler:say({tablica})` z wieloma tekstami
- ❌ Brak obsługi `player:sendTextMessage()`
- ❌ Brak obsługi `voices` i `keywordHandler`
- ❌ Brak parsera PHP/C++/Twig
- ❌ **Brak automatycznego tłumaczenia** (tryb TRANSLATION wymaga interaktywnego terminala)
- ❌ **Brak automatycznego przejścia** z MIGRATION → TRANSLATION → DOCUMENTATION
- ❌ Brak walidacji poprawności kodu po modyfikacji
- ❌ Brak rollback w przypadku błędów

---

## 🚀 Faza 1: Optymalizacja Workera

### 1.1 Wielowątkowość / Równoległe przetwarzanie

**Cel**: Przyspieszenie przetwarzania plików

**Skrypt**: `i18n_parallel_worker.sh`

```
Koncepcja:
- Podział plików na partie (batches) po 50-100 plików
- Uruchomienie N procesów równoległych (np. 4)
- Każdy proces przetwarza swoją partię
- Synchronizacja wyników do wspólnego pliku JSON
- Mutex/lock na plikach JSON podczas zapisu
```

**Korzyści**:
- 4x szybsze przetwarzanie
- Lepsze wykorzystanie CPU

---

### 1.2 Inteligentne wykrywanie zmian

**Cel**: Przetwarzanie tylko zmienionych plików

**Skrypt**: `i18n_incremental_worker.sh`

```
Koncepcja:
- Przechowywanie hash MD5/SHA256 każdego przetworzonego pliku
- Plik: .i18n_file_hashes.json
- Przy każdym cyklu: porównanie hashy
- Przetwarzanie tylko plików ze zmienionym hashem
- Obsługa nowych plików (brak hashu = nowy)
- Obsługa usuniętych plików (hash bez pliku = usuń klucze)
```

**Struktura hashy**:
```json
{
  "data-otservbr-global/npc/john.lua": {
    "hash": "a1b2c3d4...",
    "last_processed": "2025-12-08T18:00:00Z",
    "keys_count": 15
  }
}
```

---

### 1.3 Checkpoint i Resume

**Cel**: Możliwość wznowienia od miejsca przerwania

**Skrypt**: `i18n_checkpoint_manager.sh`

```
Koncepcja:
- Co 100 plików: zapis checkpoint do .i18n_checkpoint.json
- Checkpoint zawiera:
  - Lista przetworzonych plików
  - Aktualny katalog
  - Liczniki statystyk
  - Timestamp
- Przy starcie: sprawdź czy jest checkpoint
- Jeśli tak: zapytaj o resume lub fresh start
- Po zakończeniu pełnego cyklu: usuń checkpoint
```

---

### 1.4 Zaawansowane logowanie

**Cel**: Lepsze monitorowanie i debugging

**Skrypt**: `i18n_logger.sh` (library)

```
Koncepcja:
- Poziomy logów: DEBUG, INFO, WARN, ERROR, FATAL
- Rotacja logów (max 10 plików, max 10MB każdy)
- Osobne logi dla różnych komponentów:
  - worker.log - główny worker
  - guardian.log - guardian
  - git.log - operacje git
  - errors.log - tylko błędy
- Format: [TIMESTAMP] [LEVEL] [COMPONENT] Message
- Opcja: wysyłanie krytycznych błędów na Discord/Telegram
```

---

## 📁 Faza 2: Rozszerzenie typów plików

### 2.1 Parser C++ dla src/

**Cel**: Ekstrakcja stringów z kodu C++

**Skrypt**: `i18n_cpp_parser.sh`

```
Koncepcja:
- Skanowanie plików .cpp i .hpp w src/
- Wykrywanie wzorców:
  - player->sendTextMessage(MESSAGE_*, "text")
  - fmt::format("text {}", var)
  - std::string msg = "text"
  - #define MSG_* "text"
- Generowanie kluczy: cpp.filename.line_number lub cpp.filename.function.msg_N
- Tworzenie pliku mapowania: cpp_strings_map.json
- NIE modyfikowanie kodu C++ automatycznie (tylko raport)
```

**Wyjście**:
```json
{
  "cpp.game.player.sendTextMessage_line_123": {
    "original": "You have been killed by %s",
    "file": "src/game/game.cpp",
    "line": 123,
    "context": "player death message"
  }
}
```

---

### 2.2 Parser PHP dla html_copy/

**Cel**: Ekstrakcja stringów z kodu PHP

**Skrypt**: `i18n_php_parser.sh`

```
Koncepcja:
- Skanowanie plików .php
- Wykrywanie wzorców:
  - echo "text"
  - print "text"
  - $msg = "text"
  - define('CONST', 'text')
  - $_['key'] = 'text'
- Ignorowanie:
  - SQL queries
  - Ścieżki plików
  - Zmienne techniczne
- Generowanie: php.filename.msg_N
```

---

### 2.3 Parser HTML/Smarty/Twig

**Cel**: Ekstrakcja stringów z szablonów

**Skrypt**: `i18n_template_parser.sh`

```
Koncepcja:
- Skanowanie .html, .tpl, .twig
- Wykrywanie:
  - Tekst między tagami HTML
  - Atrybuty: title="", alt="", placeholder=""
  - Tekst w JavaScript inline
- Ignorowanie:
  - Tagi techniczne
  - Zmienne szablonów
  - Komentarze
```

---

### 2.4 Parser XML/OTBM

**Cel**: Ekstrakcja z plików konfiguracyjnych

**Skrypt**: `i18n_xml_parser.sh`

```
Koncepcja:
- Skanowanie data/XML/*.xml
- Wykrywanie atrybutów z tekstem:
  - name="..."
  - description="..."
  - text="..."
- Mapowanie do kluczy: xml.items.item_1234.name
```

---

### 2.5 Uniwersalny silnik parserów

**Cel**: Jeden interfejs dla wszystkich parserów

**Skrypt**: `i18n_universal_parser.sh`

```
Koncepcja:
- Konfiguracja w YAML/JSON:
  parsers:
    lua:
      extensions: [.lua]
      patterns:
        - regex: 'sendTextMessage\([^,]+,\s*"([^"]+)"'
          key_template: "{category}.{filename}.msg_{n}"
    cpp:
      extensions: [.cpp, .hpp]
      patterns: [...]
- Dynamiczne ładowanie reguł
- Łatwe dodawanie nowych typów plików
```

---

## 🌍 Faza 3: System tłumaczeń

### 3.1 Auto-tłumaczenie przez API

**Cel**: Automatyczne tłumaczenie na 53 języki

**Skrypt**: `i18n_auto_translator.sh`

```
Koncepcja:
- Integracja z API tłumaczeń:
  - Google Translate API (płatne, wysokiej jakości)
  - DeepL API (płatne, bardzo wysokiej jakości)
  - LibreTranslate (darmowe, self-hosted)
  - Lingva Translate (darmowe)
- Kolejkowanie tłumaczeń (rate limiting)
- Cache tłumaczeń (nie tłumacz tego samego 2x)
- Priorytetyzacja języków (najpierw PL, DE, ES, PT)
- Fallback: jeśli API niedostępne, oznacz jako [NEEDS_TRANSLATION]
```

**Konfiguracja**:
```bash
# .env.translation
TRANSLATION_API=deepl
DEEPL_API_KEY=xxx
TRANSLATION_RATE_LIMIT=100  # requests per minute
PRIORITY_LANGUAGES=pl,de,es,pt,fr
```

---

### 3.2 Pamięć tłumaczeń (Translation Memory)

**Cel**: Wykorzystanie wcześniejszych tłumaczeń

**Skrypt**: `i18n_translation_memory.sh`

```
Koncepcja:
- Baza danych podobnych fraz
- Przy nowym stringu: szukaj podobnych (fuzzy match)
- Jeśli podobieństwo > 80%: zaproponuj istniejące tłumaczenie
- Uczenie się z poprawek użytkowników
- Export/import pamięci (TMX format)
```

**Struktura**:
```json
{
  "memory": [
    {
      "en": "You have gained %d experience",
      "pl": "Zdobyłeś %d doświadczenia",
      "similarity_hash": "abc123",
      "usage_count": 47
    }
  ]
}
```

---

### 3.3 Glosariusz terminów

**Cel**: Spójność tłumaczeń terminów gry

**Skrypt**: `i18n_glossary_manager.sh`

```
Koncepcja:
- Plik: i18n/glossary.json
- Definicje terminów gry:
  - "experience points" -> "punkty doświadczenia" (PL)
  - "mana" -> "mana" (nie tłumaczymy)
  - "hitpoints" -> "punkty życia"
- Wymuszanie użycia terminów z glosariusza
- Walidacja: czy tłumaczenie używa właściwych terminów
```

---

### 3.4 Walidator zmiennych i formatów

**Cel**: Sprawdzanie poprawności tłumaczeń

**Skrypt**: `i18n_validator.sh`

```
Koncepcja:
- Sprawdzanie czy tłumaczenie zawiera te same zmienne co oryginał:
  - %s, %d, %f (printf)
  - {0}, {1}, {name} (format strings)
  - {{variable}} (Lua)
- Sprawdzanie długości (czy nie za długie dla UI)
- Sprawdzanie znaków specjalnych
- Raport błędów walidacji
```

**Przykład błędu**:
```
ERROR: pl/npc.json key "npc.john.greeting"
  Original: "Hello %s, you have %d gold"
  Translation: "Witaj %s"
  Missing: %d (gold amount)
```

---

## ✅ Faza 4: Walidacja i testy

### 4.1 Test syntaktyczny Lua

**Cel**: Sprawdzenie czy zmodyfikowane pliki Lua są poprawne

**Skrypt**: `i18n_lua_syntax_test.sh`

```
Koncepcja:
- Po każdej modyfikacji pliku Lua:
  - luac -p filename.lua (sprawdzenie składni)
  - Jeśli błąd: rollback do backup, dodaj do excluded
- Batch testing wszystkich plików co noc
- Raport błędów składni
```

---

### 4.2 Test integracyjny serwera

**Cel**: Sprawdzenie czy serwer startuje z nowymi plikami

**Skrypt**: `i18n_server_test.sh`

```
Koncepcja:
- Uruchomienie serwera w trybie testowym
- Timeout 30 sekund
- Sprawdzenie czy:
  - Serwer się uruchomił
  - Załadował wszystkie NPC
  - Załadował wszystkie skrypty
  - Brak błędów w logach
- Jeśli błąd: identyfikacja problematycznego pliku
```

---

### 4.3 Testy jednostkowe funkcji i18n

**Cel**: Testowanie funkcji translate()

**Skrypt**: `i18n_unit_tests.lua`

```
Koncepcja:
- Testy w Lua:
  - Test ładowania plików JSON
  - Test funkcji translate(key, lang)
  - Test fallback do EN
  - Test zmiennych w stringach
  - Test brakujących kluczy
- Integracja z CI/CD
```

---

### 4.4 Regression testing

**Cel**: Wykrywanie regresji po zmianach

**Skrypt**: `i18n_regression_test.sh`

```
Koncepcja:
- Snapshot aktualnego stanu (baseline)
- Po zmianach: porównanie z baseline
- Wykrywanie:
  - Usunięte klucze (mogą być używane!)
  - Zmienione klucze (czy zamierzone?)
  - Nowe klucze bez tłumaczeń
- Raport różnic
```

---

## 🔧 Faza 5: Integracja z serwerem

### 5.1 Loader i18n dla serwera C++

**Cel**: Ładowanie tłumaczeń w serwerze

**Plik**: `src/i18n/i18n_loader.cpp`

```
Koncepcja:
- Klasa I18nLoader:
  - loadTranslations(lang) - ładuje JSON dla języka
  - translate(key, lang) - zwraca tłumaczenie
  - translateFormat(key, lang, args...) - z formatowaniem
- Cache w pamięci
- Hot-reload bez restartu serwera
- Fallback: key -> EN -> zwróć klucz
```

---

### 5.2 Konfiguracja języka gracza

**Cel**: Przechowywanie preferencji językowych

**Plik**: `src/i18n/player_language.cpp`

```
Koncepcja:
- Nowa kolumna w bazie: players.language VARCHAR(5)
- Komenda: /language pl
- Automatyczne wykrywanie z IP (GeoIP)
- Domyślny język serwera w config.lua
```

---

### 5.3 API REST dla tłumaczeń

**Cel**: Endpoint do pobierania tłumaczeń przez klienta

**Plik**: `src/server/network/i18n_endpoint.cpp`

```
Koncepcja:
- GET /api/i18n/{lang} - wszystkie tłumaczenia
- GET /api/i18n/{lang}/{category} - kategoria (npc, items)
- Cache HTTP (ETag, Last-Modified)
- Kompresja gzip
- Wersjonowanie (?v=1.2.3)
```

---

### 5.4 Moduł Lua i18n

**Cel**: Funkcje Lua do tłumaczeń

**Plik**: `data/libs/i18n.lua`

```
Koncepcja:
- I18n.translate(key, lang, params)
- I18n.translateForPlayer(player, key, params)
- I18n.setPlayerLanguage(player, lang)
- I18n.getAvailableLanguages()
- I18n.reload() - przeładowanie bez restartu
```

---

## 🖥️ Faza 6: Panel administracyjny

### 6.1 Web UI do zarządzania tłumaczeniami

**Cel**: Interfejs graficzny dla tłumaczy

**Katalog**: `html_copy/admin/i18n/`

```
Koncepcja:
- Dashboard:
  - Statystyki (ile przetłumaczono, ile brakuje)
  - Wykresy postępu
  - Ostatnie zmiany
- Lista kluczy:
  - Filtrowanie po kategorii, języku, statusie
  - Wyszukiwanie
  - Sortowanie
- Edytor tłumaczeń:
  - Oryginał (EN) obok tłumaczenia
  - Podpowiedzi z Translation Memory
  - Walidacja w czasie rzeczywistym
- Historia zmian:
  - Kto, kiedy, co zmienił
  - Możliwość przywrócenia poprzedniej wersji
```

---

### 6.2 System ról i uprawnień

**Cel**: Kontrola dostępu dla tłumaczy

```
Koncepcja:
Role:
- Admin: pełen dostęp
- Translator: edycja przypisanych języków
- Reviewer: zatwierdzanie tłumaczeń
- Viewer: tylko odczyt

Uprawnienia:
- Przypisanie języków do użytkownika
- Wymaganie review przed publikacją
- Blokowanie kluczy (system only)
```

---

### 6.3 Import/Export

**Cel**: Wymiana danych z zewnętrznymi narzędziami

**Skrypt**: `i18n_import_export.sh`

```
Koncepcja:
Formaty:
- JSON (natywny)
- CSV (dla Excel)
- XLIFF (standard lokalizacji)
- PO/POT (gettext)
- TMX (Translation Memory Exchange)

Funkcje:
- Export wybranych języków/kategorii
- Import z walidacją
- Merge z istniejącymi danymi
- Raport konfliktów
```

---

### 6.4 Powiadomienia i workflow

**Cel**: Automatyzacja procesu tłumaczenia

```
Koncepcja:
- Powiadomienia email/Discord:
  - Nowe klucze do tłumaczenia
  - Tłumaczenie wymaga review
  - Błędy walidacji
- Workflow:
  - DRAFT -> TRANSLATED -> REVIEWED -> PUBLISHED
  - Automatyczne przypisanie do tłumacza
  - Deadline tracking
```

---

## 🔄 Faza 7: Automatyzacja CI/CD

### 7.1 GitHub Actions dla i18n

**Cel**: Automatyczne testy i deployment

**Plik**: `.github/workflows/i18n.yml`

```yaml
Koncepcja:
Triggers:
- Push do i18n/
- Pull Request z zmianami tłumaczeń
- Scheduled (codziennie o 3:00)

Jobs:
1. validate:
   - Sprawdź składnię JSON
   - Sprawdź zmienne w tłumaczeniach
   - Sprawdź duplikaty kluczy

2. test:
   - Testy jednostkowe
   - Test ładowania na serwerze

3. stats:
   - Generowanie statystyk
   - Update README badges

4. deploy:
   - Sync do serwera produkcyjnego
   - Invalidacja cache
```

---

### 7.2 Pre-commit hooks

**Cel**: Walidacja przed commitem

**Plik**: `.pre-commit-config.yaml`

```
Koncepcja:
Hooks:
- json-lint: sprawdź składnię JSON
- i18n-validate: sprawdź zmienne
- i18n-no-empty: brak pustych tłumaczeń
- i18n-keys-sorted: klucze posortowane alfabetycznie
```

---

### 7.3 Automatyczne release notes

**Cel**: Dokumentacja zmian w tłumaczeniach

**Skrypt**: `i18n_release_notes.sh`

```
Koncepcja:
- Przy każdym release:
  - Lista nowych kluczy
  - Lista zmienionych tłumaczeń
  - Statystyki pokrycia na język
- Format Markdown
- Automatyczny commit do CHANGELOG_I18N.md
```

---

### 7.4 Monitoring i alerty

**Cel**: Monitorowanie systemu i18n

**Skrypt**: `i18n_monitoring.sh`

```
Koncepcja:
Metryki:
- Liczba kluczy (total, per language)
- Procent pokrycia
- Błędy walidacji
- Czas przetwarzania workera

Alerty (Discord/Telegram/Email):
- Worker nie działa > 5 min
- Błąd składni w JSON
- Pokrycie spadło poniżej 80%
- Nowe klucze bez tłumaczeń > 100
```

---

## 📜 Skrypty do stworzenia

### Priorytet: KRYTYCZNY (P0)

| Skrypt | Opis | Estymacja |
|--------|------|-----------|
| `i18n_incremental_worker.sh` | Przetwarzanie tylko zmienionych plików | 4h |
| `i18n_lua_syntax_test.sh` | Walidacja składni Lua po modyfikacji | 2h |
| `i18n_validator.sh` | Walidacja zmiennych w tłumaczeniach | 3h |
| `i18n_rollback.sh` | Przywracanie z backup przy błędzie | 2h |

### Priorytet: WYSOKI (P1)

| Skrypt | Opis | Estymacja |
|--------|------|-----------|
| `i18n_cpp_parser.sh` | Ekstrakcja stringów z C++ | 6h |
| `i18n_php_parser.sh` | Ekstrakcja stringów z PHP | 4h |
| `i18n_auto_translator.sh` | Integracja z API tłumaczeń | 8h |
| `i18n_translation_memory.sh` | Pamięć tłumaczeń | 6h |
| `i18n_glossary_manager.sh` | Zarządzanie glosariuszem | 3h |

### Priorytet: ŚREDNI (P2)

| Skrypt | Opis | Estymacja |
|--------|------|-----------|
| `i18n_parallel_worker.sh` | Wielowątkowe przetwarzanie | 5h |
| `i18n_checkpoint_manager.sh` | Checkpoint i resume | 3h |
| `i18n_logger.sh` | Zaawansowane logowanie | 2h |
| `i18n_server_test.sh` | Test integracyjny serwera | 4h |
| `i18n_import_export.sh` | Import/export formatów | 6h |

### Priorytet: NISKI (P3)

| Skrypt | Opis | Estymacja |
|--------|------|-----------|
| `i18n_template_parser.sh` | Parser HTML/Twig | 4h |
| `i18n_xml_parser.sh` | Parser XML | 3h |
| `i18n_universal_parser.sh` | Uniwersalny silnik | 8h |
| `i18n_regression_test.sh` | Testy regresji | 4h |
| `i18n_release_notes.sh` | Automatyczne release notes | 2h |
| `i18n_monitoring.sh` | System monitoringu | 4h |

---

## 📅 Priorytety i harmonogram

### Sprint 1 (Tydzień 1-2): Stabilizacja
- [ ] `i18n_incremental_worker.sh`
- [ ] `i18n_lua_syntax_test.sh`
- [ ] `i18n_validator.sh`
- [ ] `i18n_rollback.sh`
- [ ] Testy obecnego systemu

### Sprint 2 (Tydzień 3-4): Rozszerzenie parserów
- [ ] `i18n_cpp_parser.sh`
- [ ] `i18n_php_parser.sh`
- [ ] Dokumentacja wyekstrahowanych stringów C++/PHP
- [ ] Plan integracji z kodem źródłowym

### Sprint 3 (Tydzień 5-6): System tłumaczeń
- [ ] `i18n_auto_translator.sh`
- [ ] `i18n_translation_memory.sh`
- [ ] `i18n_glossary_manager.sh`
- [ ] Tłumaczenie PL, DE, ES, PT

### Sprint 4 (Tydzień 7-8): Integracja serwera
- [ ] `src/i18n/i18n_loader.cpp`
- [ ] `src/i18n/player_language.cpp`
- [ ] `data/libs/i18n.lua`
- [ ] Testy na serwerze testowym

### Sprint 5 (Tydzień 9-10): Panel administracyjny
- [ ] Web UI podstawowy
- [ ] System ról
- [ ] Import/Export

### Sprint 6 (Tydzień 11-12): CI/CD i monitoring
- [ ] GitHub Actions
- [ ] Pre-commit hooks
- [ ] Monitoring i alerty
- [ ] Dokumentacja końcowa

---

## 🎯 KPI (Key Performance Indicators)

| Metryka | Cel | Obecny |
|---------|-----|--------|
| Pokrycie EN | 100% | ~95% |
| Pokrycie PL | 100% | 0% |
| Pokrycie pozostałe | >50% | 0% |
| Czas przetwarzania 1 pliku | <100ms | ~200ms |
| Błędy składni po modyfikacji | 0% | ~2% |
| Uptime workera | 99.9% | ~95% |
| Czas do tłumaczenia nowego klucza | <24h | N/A |

---

## 📝 Notatki implementacyjne

### Technologie do rozważenia:
- **jq** - przetwarzanie JSON w bash
- **yq** - przetwarzanie YAML
- **GNU parallel** - równoległe przetwarzanie
- **SQLite** - lokalna baza dla Translation Memory
- **Redis** - cache dla API tłumaczeń
- **Docker** - izolacja środowiska testowego

### Potencjalne problemy:
1. **Rate limiting API tłumaczeń** - rozwiązanie: kolejkowanie, cache
2. **Konflikty przy równoległym zapisie JSON** - rozwiązanie: file locking
3. **Duże pliki JSON (>10MB)** - rozwiązanie: podział na mniejsze pliki
4. **Encoding UTF-8** - rozwiązanie: konsekwentne używanie UTF-8 wszędzie
5. **Zmienne w różnych formatach** - rozwiązanie: normalizacja do jednego formatu

### Backwards compatibility:
- Stare pliki Lua muszą działać bez i18n
- Fallback do hardcoded stringów
- Graceful degradation przy braku tłumaczenia

---

## 🔗 Powiązane dokumenty

- [I18N_STATUS.md](../I18N_STATUS.md) - Aktualny status
- [i18n_full_documentation.md](../i18n_full_documentation.md) - Pełna dokumentacja
- [I18N_CHECKLIST_SERVER.md](./I18N_CHECKLIST_SERVER.md) - Checklist wdrożenia
- [I18N_PL_ROADMAP.md](./I18N_PL_ROADMAP.md) - Plan tłumaczenia PL

---

*Dokument będzie aktualizowany wraz z postępem prac.*

**Ostatnia aktualizacja**: 2025-12-08
