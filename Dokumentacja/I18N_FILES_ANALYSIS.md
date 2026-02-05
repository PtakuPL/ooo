# 🌍 Analiza Plików Wymagających Wielojęzyczności (i18n)

> **Data analizy:** 2025-02-04  
> **Repozytorium:** PtakuPL/ooo  
> **Status systemu:** Aktywna migracja i18n w toku

---

## 📊 Podsumowanie

System wielojęzyczności (i18n) jest już **częściowo zaimplementowany** w repozytorium. Poniżej znajduje się szczegółowa analiza plików wymagających wprowadzenia wielojęzyczności.

### Aktualny status:
| Metryka | Wartość | Procent |
|---------|---------|---------|
| 🔑 Klucze EN (źródłowe) | **~36,454** | - |
| 🌐 Obsługiwane języki | **54** | - |
| ✅ Przetłumaczone języki | **53** | 98% |
| 📁 Pliki przeskanowane | **~6,442** | 79% |
| ⏳ Pliki do skanowania | **~1,714** | 21% |

---

## 🎮 FAZA 1: Serwer Canary (Silnik Tibia)

### 1️⃣ Pliki NPC (Dialogi) - `.lua`

**Lokalizacja:** `Tibia/silnik/canary_test/data-otservbr-global/npc/`

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Wszystkie pliki NPC | **~1,027** | Dialogi postaci NPC |
| ✅ Zmigrowane | **~695** | Z kluczami i18n |
| 🔄 Do migracji automatycznej | **~14** | Proste teksty |
| 📝 Do ręcznej edycji | **~135** | Dynamiczne teksty (konkatenacja Lua `..`) |
| ⏳ Pozostałe | **~183** | W kolejce |

**Przykłady plików do migracji:**
```
data-otservbr-global/npc/oressa.lua    (dynamiczne teksty)
data-otservbr-global/npc/dalbrect.lua  (w trakcie)
```

**Metoda migracji:**
- `sayLocalized()` - dla zwykłych dialogów
- `NPC_LIB.i18n.setLocalizedMessage()` - dla MESSAGE_GREET/FAREWELL

---

### 2️⃣ Skrypty Lua - `.lua`

**Lokalizacja:** `Tibia/silnik/canary_test/data-otservbr-global/scripts/`

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Wszystkie skrypty | **~1,755** | Quest, eventy, akcje |
| ✅ Zmigrowane klucze | **641/1000** | 64% |
| ⏳ Do migracji | **~359** | - |

**Podkategorie:**
- `scripts/actions/` - akcje przedmiotów
- `scripts/globalevents/` - zdarzenia globalne
- `scripts/creaturescripts/` - skrypty kreatur
- `scripts/quests/` - misje

---

### 3️⃣ Potwory (Monsters) - `.lua`

**Lokalizacja:** `Tibia/silnik/canary_test/data-otservbr-global/monster/`

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Pliki potworów | **~1,637** | Definicje potworów |
| ✅ Zmigrowane klucze | **5,915/6,000** | 99% ✅ |
| ⏳ Do migracji | **~85** | Pozostałe |

---

### 4️⃣ Zaklęcia (Spells) - `.lua`

**Lokalizacja:** `Tibia/silnik/canary_test/data/spells/`

| Status | Ilość | Opis |
|--------|-------|------|
| ✅ Zmigrowane klucze | **1,526/2,000** | 76% |
| ⏳ Do migracji | **~474** | - |

---

### 5️⃣ Przedmioty (Items) - `.json`

**Lokalizacja:** `Tibia/silnik/canary_test/i18n/en/items.json`

| Status | Ilość | Opis |
|--------|-------|------|
| ✅ Zmigrowane klucze | **16,761/40,000** | 42% |
| ⏳ Do migracji | **~23,239** | Nazwy i opisy przedmiotów |

---

### 6️⃣ Silnik C++ Serwera

**Lokalizacja:** `Tibia/silnik/canary_test/src/`

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Pliki C++ | **437** | `.cpp` i `.hpp` |
| ✅ Zmigrowane klucze | **66/300** | 22% |
| ⏳ Do migracji | **~234** | Komunikaty systemowe |

**Główne pliki wymagające i18n:**
```
src/server/network/protocol/protocolgame*.cpp  - komunikaty gry
src/creatures/players/player.cpp               - wiadomości gracza
src/game/game.cpp                              - logika gry
src/io/io*.cpp                                 - operacje I/O
src/lua/functions/*.cpp                        - funkcje Lua
```

---

## 🌐 FAZA 2: Strona WWW (AAC - Automatic Account Creator)

**Lokalizacja:** `Tibia/silnik/canary_test/html_copy/`

### 1️⃣ Pliki PHP (Backend)

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Pliki PHP | **~5,563** | Backend strony |
| ✅ Zmigrowane klucze | **59/3,000** | 2% |
| ⏳ Do migracji | **~2,941** | Etykiety, komunikaty |

**Główne foldery:**
```
html_copy/app/                    - logika aplikacji
html_copy/admin/                  - panel administracyjny
html_copy/system/pages/           - strony systemu
```

---

### 2️⃣ Pliki HTML (Widoki)

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Pliki HTML | **~57** | Szablony widoków |
| ✅ Zmigrowane klucze | **1,495** | ✅ Ukończone (cel 300 - przekroczony) |

---

### 3️⃣ JavaScript (Frontend)

| Status | Ilość | Opis |
|--------|-------|------|
| ✅ Zmigrowane klucze | **242/300** | 81% |
| ⏳ Do migracji | **~58** | - |

---

## 📱 FAZA 3: OTClient (Klient Tibia)

**Lokalizacja:** `Tibia/silnik/canary_test/testyy/`

### 1️⃣ Moduły Lua OTClient

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Pliki modułów | **~173** | Interfejs użytkownika |
| ✅ Zmigrowane klucze | **1,987** | ✅ Ukończone (cel 500 - przekroczony) |

**Lokalizacja:** `testyy/modules/`

---

### 2️⃣ Dane OTClient

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Pliki danych | **~111** | Konfiguracje |
| ✅ Zmigrowane klucze | **72/200** | 36% |
| ⏳ Do migracji | **~128** | - |

**Lokalizacja:** `testyy/data/`

---

### 3️⃣ Źródła C++ OTClient

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Pliki C++ | **~172** | Silnik klienta |
| ⏳ Do migracji | **~300** | 0% |

**Lokalizacja:** `testyy/src/`

**Główne pliki wymagające i18n:**
```
testyy/src/client/          - logika klienta
testyy/src/framework/ui/    - interfejs użytkownika
testyy/src/framework/core/  - rdzeń frameworka
```

---

### 4️⃣ Mody OTClient

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Pliki modów | - | Dodatki |
| ⏳ Do migracji | **~100** | 0% |

**Lokalizacja:** `testyy/mods/`

---

### 5️⃣ Narzędzia OTClient

| Status | Ilość | Opis |
|--------|-------|------|
| 📁 Pliki narzędzi | - | Utilities |
| ⏳ Do migracji | **~50** | 0% |

**Lokalizacja:** `testyy/tools/`

---

## 📋 SZCZEGÓŁOWA LISTA KATEGORII I18N

### Pliki JSON z kluczami (EN jako źródło):

| Plik | Klucze | Status |
|------|--------|--------|
| `i18n/en/items.json` | 13,750 | 🔄 42% |
| `i18n/en/npc.json` | 7,244 | 🔄 48% |
| `i18n/en/otclient_modules.json` | 1,988 | ✅ Ukończone |
| `i18n/en/html.json` | 1,496 | ✅ Ukończone |
| `i18n/en/spells.json` | 1,427 | 🔄 76% |
| `i18n/en/scripts.json` | 642 | 🔄 64% |
| `i18n/en/client.json` | 243 | 🔄 81% |
| `i18n/en/raids.json` | 148 | ✅ |
| `i18n/en/monsters.json` | 133 | ✅ 99% |
| `i18n/en/quests.json` | 118 | 🔄 26% |
| `i18n/en/otclient_data.json` | 73 | 🔄 36% |
| `i18n/en/server.json` | 67 | 🔄 22% |
| `i18n/en/php.json` | 60 | 🔄 2% |
| `i18n/en/startup.json` | 24 | ✅ |
| `i18n/en/actions.json` | 22 | ✅ |
| `i18n/en/libs.json` | 22 | ✅ |
| `i18n/en/example_merchant.json` | 18 | ✅ |
| `i18n/en/modules.json` | 17 | ✅ |
| `i18n/en/messages.json` | 12 | ✅ |
| `i18n/en/chatchannels.json` | 9 | ✅ |
| `i18n/en/events.json` | 6 | ✅ |
| `i18n/en/dataroot.json` | 4 | ✅ |
| `i18n/en/creaturescripts.json` | 3 | ✅ |

---

## 🛠️ NARZĘDZIA DO MIGRACJI

### Automatyczna migracja (Worker):
```bash
# Uruchom worker dla pojedynczego pliku
./i18n_worker_simple.sh --file data-otservbr-global/npc/nazwa.lua

# Status lokalny
./i18n_worker_simple.sh --status

# Auto migracja (5 plików)
./i18n_worker_simple.sh --auto 5

# Aktualizuj status
./i18n_worker_simple.sh --update-status
```

### Parsery dla różnych języków:
- `i18n_future_scripts/parsers/i18n_cpp_parser.sh` - C++
- `i18n_future_scripts/parsers/i18n_php_parser.sh` - PHP
- `i18n_process_say_arrays.py` - Lua (tablice dialogów)

---

## 📝 PLIKI WYMAGAJĄCE RĘCZNEJ EDYCJI

Lista plików z dynamicznymi tekstami (konkatenacja Lua `..`):

**Lokalizacja:** `i18n_manual_review.txt`

Przykłady wzorców wymagających ręcznej pracy:
```lua
-- PRZED:
npcHandler:setMessage(MESSAGE_GREET, "Hello " .. creature:getName() .. "!")

-- PO (z interpolacją):
npcHandler:setMessage(MESSAGE_GREET, I18n.get("npc.name.greet", {name = creature:getName()}))
```

---

## 🌍 OBSŁUGIWANE JĘZYKI (54)

| Kod | Język | Status TM |
|-----|-------|-----------|
| de | Niemiecki | ✅ TM |
| es | Hiszpański | ✅ TM |
| pl | Polski | ✅ TM |
| pt | Portugalski | ✅ TM |
| fr | Francuski | ⚠️ placeholder |
| it | Włoski | ⚠️ placeholder |
| ru | Rosyjski | ⚠️ placeholder |
| tr | Turecki | ⚠️ placeholder |
| ... | +46 innych | ⚠️ placeholder |

**Uwaga:** Języki z "placeholder" mają klucze EN z prefixem `[EN]` do przetłumaczenia.

---

## 📅 PRIORYTET MIGRACJI

1. **🔴 Wysoki:** NPC Dialogi (wpływa na gameplay)
2. **🔴 Wysoki:** Komunikaty błędów serwera C++
3. **🟡 Średni:** Przedmioty (items) - nazwy i opisy
4. **🟡 Średni:** Strona WWW (AAC) - PHP
5. **🟢 Niski:** OTClient C++ (klient)
6. **🟢 Niski:** Mody OTClient

---

*Wygenerowano automatycznie przez system analizy i18n*  
*Aktualizacja statusu: Zobacz `I18N_STATUS.md` w głównym katalogu*
