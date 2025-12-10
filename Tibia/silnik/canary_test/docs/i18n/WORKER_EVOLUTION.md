# 🔧 I18N Worker - Historia Ewolucji

## Spis Treści
1. [Podsumowanie](#podsumowanie)
2. [Wersje Workerów](#wersje-workerów)
3. [Dlaczego porzuciliśmy stare wersje?](#dlaczego-porzuciliśmy-stare-wersje)
4. [Architektura aktualnego rozwiązania](#architektura-aktualnego-rozwiązania)
5. [Jak używać](#jak-używać)

---

## Podsumowanie

| Wersja | Plik | Status | Problem |
|--------|------|--------|---------|
| v1.0 | `i18n_autonomous_worker.sh` | ❌ Porzucony | Tylko ekstrakcja, brak transformacji kodu |
| v2.0 | `i18n_autonomous_worker.sh.bak` | ❌ Porzucony | Używał `sayLocalized()` - funkcji która nie istnieje |
| v3.0 | `i18n_autonomous_worker.sh.bak2` | ❌ Porzucony | Błędy w pipeline, niestabilny |
| v4.0 | `i18n_autonomous_worker.sh.old` | ❌ Porzucony | Złożony, trudny do debugowania |
| v5.0 | `i18n_worker_v5.sh` | ❌ Porzucony | Eksperymentalny, nie ukończony |
| **v6.0** | **`i18n_worker_simple.sh`** | ✅ **AKTUALNY** | Prosty, 8-etapowy, działa |

**Aktualnie używamy: `i18n_worker_simple.sh` v1.1 (v6 koncepcyjnie)**

---

## Wersje Workerów

### v1.0 - Pierwszy Worker (Grudzień 2025)
**Plik:** `i18n_autonomous_worker.sh` (oryginalna wersja)

**Co robił:**
- Skanował pliki Lua w poszukiwaniu stringów
- Ekstrahował teksty do plików JSON
- Generował raporty

**Problem:**
- ❌ **Tylko ekstrakcja** - wyciągał klucze do JSON, ale NIE zmieniał kodu źródłowego
- Kod Lua pozostawał niezmieniony - nadal miał hardkodowane stringi
- Pliki NPC dalej używały `text = "Hello"` zamiast kluczy i18n

```lua
-- PRZED (bez zmian):
StdModule.say(npc, creature, "Hello adventurer!")

-- OCZEKIWANE (ale v1 tego nie robił):
StdModule.say(npc, creature, "Hello adventurer!", {i18nKey = "npc.name.greeting"})
```

---

### v2.0 - Próba z sayLocalized()
**Plik:** `i18n_autonomous_worker.sh.bak`

**Co robił:**
- Próbował zamienić `StdModule.say` na `StdModule.sayLocalized`
- Generował klucze i18n

**Problem:**
- ❌ **sayLocalized() NIE ISTNIEJE** w `modules.lua`!
- Funkcja nigdy nie została zaimplementowana w silniku
- Wszystkie "zmigrowane" pliki były zepsute - wywoływały nieistniejącą funkcję

```lua
-- v2 generował (BŁĘDNIE):
StdModule.sayLocalized(npc, creature, "npc.alexander.greeting")

-- Ale sayLocalized() nie istnieje w modules.lua!
-- Powodowało błędy runtime na serwerze
```

---

### v3.0 & v4.0 - Złożone Pipeline'y
**Pliki:** `i18n_autonomous_worker.sh.bak2`, `i18n_autonomous_worker.sh.old`

**Co robiły:**
- Wieloetapowe przetwarzanie (15+ etapów)
- Obsługa wielu typów plików (Lua, C++, PHP, HTML)
- Automatyczne tłumaczenia
- Statystyki i raportowanie

**Problemy:**
- ❌ Zbyt skomplikowane - trudne do debugowania
- ❌ Niestabilne - często się zawieszały
- ❌ Mieszały logikę ekstrakcji z transformacją
- ❌ Brak jasnego podziału na etapy
- ❌ Statystyki się nie zgadzały z rzeczywistością

---

### v5.0 - Eksperymentalna
**Plik:** `i18n_worker_v5.sh`

**Co robił:**
- Próba uproszczenia logiki
- Focus na pliki NPC

**Problem:**
- ❌ Nie ukończony
- ❌ Brak pełnego pipeline'u
- ❌ Porzucony na rzecz v6

---

### v6.0 - Worker Simple (AKTUALNY) ✅
**Plik:** `i18n_worker_simple.sh`

**Data utworzenia:** 10 grudnia 2025
**Aktualizacja do v2.0:** 10 grudnia 2025

**Kluczowe cechy v2.0:**
1. **Multi-Mode** - Automatyczne przełączanie między trybami pracy
2. **TRYB 1: MIGRATION** - 8-etapowy pipeline migracji kodu NPC
3. **TRYB 2: TRANSLATION** - 6-etapowy pipeline tłumaczeń ze składniami
4. **Dispatcher** - Automatycznie wybiera tryb na podstawie stanu projektu
5. **Składnie** - Tłumaczenia podzielone na małe paczki (4 klucze na składnię)

**Tryby pracy:**
```
┌─────────────────────────────────────────────────────────────────┐
│                    DISPATCHER                                    │
│  1. Czy są pliki NPC do migracji? → TRYB 1: MIGRATION           │
│  2. Czy są klucze do przetłumaczenia? → TRYB 2: TRANSLATION     │
│  3. Wszystko zrobione → IDLE                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Dlaczego porzuciliśmy stare wersje?

### Główne powody:

#### 1. Brak rzeczywistej transformacji kodu
Stare workery TYLKO ekstrahowały stringi do JSON, ale **nie zmieniały kodu Lua**.
To było jak robienie spisu zakupów bez kupowania czegokolwiek.

```
STARY WORKER:
  Plik.lua → [Ekstrakcja] → klucze.json
  Plik.lua pozostaje NIEZMIENIONY!

NOWY WORKER:
  Plik.lua → [Ekstrakcja] → [TRANSFORMACJA] → Plik.lua zmieniony + klucze.json
```

#### 2. Nieistniejące funkcje
Worker v2 używał `sayLocalized()` która nigdy nie istniała.
Musieliśmy użyć istniejącego API - parametru `i18nKey` w `StdModule.say`.

#### 3. Złożoność vs prostota
Stare workery miały 15+ etapów, były trudne do debugowania.
Nowy ma 8 jasno zdefiniowanych etapów.

#### 4. Brak weryfikacji
Stare workery nie sprawdzały czy transformacja się udała.
Nowy ma etap VALIDATION który sprawdza spójność.

---

## Architektura aktualnego rozwiązania

### Pipeline 8 etapów:

```
┌─────────────────────────────────────────────────────────────────┐
│                    I18N WORKER SIMPLE v1.1                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [1] STARTED        → Rejestracja pliku, hash, typ             │
│         ↓                                                       │
│  [2] ANALYSIS       → Analiza StdModule.say, ile do migracji   │
│         ↓                                                       │
│  [3] DOCUMENTATION  → Generowanie docs/i18n/npc/name.md        │
│         ↓                                                       │
│  [4] TRANSFORMATION → KLUCZOWY: text= → i18nKey=               │
│         ↓                                                       │
│  [5] EXTRACTION_EN  → Wyciągnięcie kluczy do en/npc.json       │
│         ↓                                                       │
│  [6] TRANSLATION    → Placeholder tłumaczenia (7 języków)      │
│         ↓                                                       │
│  [7] VALIDATION     → Sprawdzenie spójności klucze↔kod         │
│         ↓                                                       │
│  [8] SYNC           → Aktualizacja statusu, I18N_STATUS.md     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Kluczowa zmiana w modules.lua:

```lua
-- data/libs/systems/modules.lua (linie 72-86)
function StdModule.say(npc, creature, message, parameters)
    parameters = parameters or {}
    
    local textToSay = message
    
    -- NOWE: Obsługa i18nKey
    if parameters.i18nKey then
        local translated = I18N.get(parameters.i18nKey, {creature = creature})
        if translated and translated ~= parameters.i18nKey then
            textToSay = translated
        end
    end
    
    return msgcontains(message, textToSay)
end
```

### Jak wygląda zmigrowany plik NPC:

```lua
-- PRZED (hardkodowane):
keywordHandler:addKeyword({"hi"}, StdModule.say, 
    {npcHandler = npcHandler, text = "Hello adventurer! Welcome to my shop."})

-- PO MIGRACJI (z i18nKey):
keywordHandler:addKeyword({"hi"}, StdModule.say, 
    {npcHandler = npcHandler, text = "Hello adventurer! Welcome to my shop.", 
     i18nKey = "npc.alexander.greeting"})
```

---

## Jak używać

### Uruchomienie workera (tryb ciągły):
```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test
./i18n_worker_simple.sh --continuous 5 10
# 5 = plików na batch
# 10 = sekund przerwy między batchami
```

### Przetworzenie pojedynczego pliku:
```bash
./i18n_worker_simple.sh --file data-otservbr-global/npc/alexander.lua
```

### Sprawdzenie statusu:
```bash
./i18n_worker_simple.sh --status
```

### Aktualizacja I18N_STATUS.md:
```bash
./i18n_worker_simple.sh --update-status
```

### Automatyczne przetworzenie N plików:
```bash
./i18n_worker_simple.sh --auto 10
```

---

## Pliki projektu

| Plik | Opis |
|------|------|
| `i18n_worker_simple.sh` | ✅ Główny worker v6.0 |
| `i18n_guardian.sh` | Monitor (cron) - restartuje workera jeśli padnie |
| `i18n_file_status.json` | Status każdego pliku (etapy, timestamps) |
| `I18N_STATUS.md` | Dashboard na GitHub |
| `data/i18n/*/npc.json` | Pliki tłumaczeń per język |
| `docs/i18n/npc/*.md` | Dokumentacja per NPC |

---

## Statystyki (grudzień 2025)

- **Zmigrowanych NPC:** ~25+ (rośnie w trybie ciągłym)
- **Kluczy i18n:** ~350+ 
- **Języków:** 8 (de, en, es, fr, it, pl, pt, ru)
- **Do zrobienia:** ~265 NPC

---

## Wnioski

1. **Prostota wygrywa** - 8 etapów > 15 etapów
2. **Używaj istniejącego API** - nie twórz nieistniejących funkcji
3. **Transformuj kod** - ekstrakcja bez transformacji jest bezużyteczna
4. **Weryfikuj** - każda zmiana powinna być sprawdzona
5. **Automatyzuj** - tryb ciągły + guardian = zero interwencji

---

*Ostatnia aktualizacja: 10 grudnia 2025*
*Autor: AI Assistant + PtakuPL*
