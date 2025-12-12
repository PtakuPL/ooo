# 🌍 System Lokalizacji Klienta (OTClient/testyy)

> **Data utworzenia**: 2025-12-12  
> **Status**: W TRAKCIE IMPLEMENTACJI  
> **Powiązane**: Server I18N Protocol (canary_test/docs/I18N_PROTOCOL_IMPLEMENTATION.md)

---

## 📋 PODSUMOWANIE

System lokalizacji klienta pozwala na tłumaczenie tekstów gry na różne języki. 
Klient otrzymuje od serwera **klucze i18n** (krótkie identyfikatory) i tłumaczy je lokalnie
używając funkcji `tr()` i słowników w plikach `data/locales/*.lua`.

### Przepływ danych
```
SERWER                         KLIENT
┌─────────────────┐           ┌─────────────────┐
│ sendLocalizedMsg │  ──────► │ parseLocalized  │
│ key="npc.1"     │   0xBC    │ tr("npc.1")     │
│ fallback="Hi"   │           │ "Witaj!"        │
└─────────────────┘           └─────────────────┘
```

---

## 🔑 KONWENCJA KLUCZY I18N

### Prefiksy kategorii (bandwidth-optimized)

| Prefiks | Pełna nazwa | Przykład klucza | Opis |
|---------|-------------|-----------------|------|
| `npc.` | NPC dialogs | `npc.oracle.1` | Dialogi NPC |
| `nv.` | NPC voices | `nv.1` | Głosy NPC (krzyki) |
| `mv.` | Monster voices | `mv.dragon.1` | Głosy potworów |
| `mn.` | Monster names | `mn.1` | Nazwy potworów |
| `it.` | Item names | `it.1` | Nazwy przedmiotów |
| `id.` | Item descriptions | `id.1` | Opisy przedmiotów |
| `sp.` | Spell names | `sp.1` | Nazwy zaklęć |
| `cm.` | Combat messages | `cm.1` | Wiadomości walki |
| `sys.` | System messages | `sys.1` | Wiadomości systemowe |

### Format kluczy

**Długi (czytelny, development):**
```
npc.the_oracle.greeting_welcome
monster.dragon.voice_roar_1
```

**Krótki (produkcja, optymalizacja):**
```
npc.1
mv.1
mn.a
it.b2
```

### Generowanie krótkich kluczy

```lua
-- Sekwencja: 1-9, a-z, A-Z, 10-99, aa-zz, ...
-- 9 + 26 + 26 + 90 + 676 = 827 kluczy jednoznakowych/dwuznakowych

local function generateKeys(count)
    local chars = "123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local keys = {}
    for i = 1, math.min(count, #chars) do
        table.insert(keys, chars:sub(i, i))
    end
    -- Dla większej liczby: "10", "11", "aa", "ab", ...
    return keys
end
```

---

## 📂 STRUKTURA PLIKÓW LOCALES

### Położenie plików
```
testyy/
├── data/
│   └── locales/
│       ├── en.lua           # Angielski (bazowy)
│       ├── pl.lua           # Polski
│       ├── de.lua           # Niemiecki
│       ├── es.lua           # Hiszpański
│       ├── pt.lua           # Portugalski
│       └── ...
│       ├── game_i18n_en.lua # NOWY: Tłumaczenia gry (en)
│       ├── game_i18n_pl.lua # NOWY: Tłumaczenia gry (pl)
│       └── game_i18n_de.lua # NOWY: Tłumaczenia gry (de)
└── modules/
    └── client_locales/
        └── locales.lua      # System tr()
```

### Format pliku locale (istniejący)
```lua
-- data/locales/pl.lua
locale = {
  name = "pl",
  languageName = "Polski",
  formatNumbers = true,
  decimalSeperator = '.',
  thousandsSeperator = ' ',

  translation = {
    -- UI translations
    ["Accept"] = "Akceptuj",
    ["Cancel"] = "Anuluj",
    -- ...
  }
}

modules.client_locales.installLocale(locale)
```

### Format pliku game_i18n (NOWY)
```lua
-- data/locales/game_i18n_pl.lua
-- Tłumaczenia z serwera gry - NPC dialogi, głosy, nazwy

local gameTranslations = {
  -- ==========================================
  -- NPC DIALOGS (npc.*)
  -- ==========================================
  
  -- The Oracle
  ["npc.oracle.1"] = "WITAJ! CZY JESTEŚ GOTOWY STAWIĆ CZOŁA SWOJEMU PRZEZNACZENIU?",
  ["npc.oracle.2"] = "WRÓĆ KIEDY OSIĄGNIESZ POZIOM 8.",
  ["npc.oracle.3"] = "WYBRAŁEŚ JUŻ SWOJĄ PROFESJĘ. ŻEGNAJ!",
  ["npc.oracle.4"] = "GDZIE CHCIAŁBYŚ ROZPOCZĄĆ? {VENORE}, {THAIS} CZY {CARLIN}?",
  
  -- Cipfried
  ["npc.cipfried.1"] = "Witaj w świątyni, młody wędrowcze!",
  ["npc.cipfried.2"] = "Niech bogowie cię strzegą.",
  
  -- ==========================================
  -- NPC VOICES (nv.*)
  -- ==========================================
  ["nv.1"] = "Kupuj taniej u nas!",
  ["nv.2"] = "Najlepsze zbroje w mieście!",
  
  -- ==========================================
  -- MONSTER VOICES (mv.*)
  -- ==========================================
  ["mv.dragon.1"] = "CZUJĘ ZAPACH STRACHU!",
  ["mv.dragon.2"] = "SPŁONIESZ W OGNIU!",
  ["mv.rat.1"] = "*pisk* *pisk*",
  ["mv.demon.1"] = "TWOJA DUSZA NALEŻY DO MNIE!",
  
  -- ==========================================
  -- MONSTER NAMES (mn.*)
  -- ==========================================
  ["mn.1"] = "Smok",
  ["mn.2"] = "Szczur",
  ["mn.3"] = "Demon",
  ["mn.4"] = "Goblin",
  
  -- ==========================================
  -- ITEM NAMES (it.*)
  -- ==========================================
  ["it.1"] = "Magiczny Miecz",
  ["it.2"] = "Złoty Hełm",
  ["it.3"] = "Mikstura Lecznicza",
  
  -- ==========================================
  -- SPELL NAMES (sp.*)
  -- ==========================================
  ["sp.1"] = "Wielka Kula Ognia",
  ["sp.2"] = "Leczenie",
  
  -- ==========================================
  -- COMBAT MESSAGES (cm.*)
  -- ==========================================
  ["cm.hit.1"] = "%s trafił cię na %d punktów obrażeń!",
  ["cm.miss.1"] = "%s chybił!",
}

-- Merge with existing locale
if locale and locale.translation then
  for key, value in pairs(gameTranslations) do
    locale.translation[key] = value
  end
end
```

---

## 🔧 FUNKCJA tr() - JAK DZIAŁA

### Definicja (modules/client_locales/locales.lua)
```lua
function _G.tr(text, ...)
  if currentLocale then
    local translation = currentLocale.translation[text]
    if not translation then
      if translation == nil and currentLocale.name ~= defaultLocaleName then
        pdebug('Unable to translate: "' .. text .. '"')
      end
      translation = text  -- Fallback: zwróć klucz
    end
    return string.format(translation, ...)
  end
  return text
end
```

### Użycie w kodzie C++ klienta
```cpp
// protocolgameparse.cpp - parseLocalizedCreatureSay
std::string translatedText = g_lua.callGlobalField<std::string>("", "tr", i18nKey);
if (translatedText == i18nKey) {
    translatedText = fallbackText;  // Brak tłumaczenia, użyj fallback
}
```

### Użycie w Lua klienta
```lua
-- Bezpośrednio
local text = tr("npc.oracle.1")

-- Z parametrami (string.format)
local text = tr("cm.hit.1", "Dragon", 150)
-- Wynik: "Dragon trafił cię na 150 punktów obrażeń!"
```

---

## 📡 PROTOKÓŁ SERWER → KLIENT

### Opcode 0xBC (188) - LocalizedTextMessage
Wiadomości systemowe z kluczem i18n.

```
[0xBC][type:u8][...data...][text:string][i18nKey:string]
                            ↑ fallback   ↑ klucz dla tr()
```

### Opcode 0x99 (153) - LocalizedCreatureSay  
Głosy monster/NPC z kluczem i18n.

```
[0x99][statementId:u32][name:string][suffix:u8][level:u16]
[talkType:u8][position:xyz][i18nKey:string][fallbackText:string]
                           ↑ klucz tr()   ↑ dla starych klientów
```

---

## 📝 ZADANIA DLA WORKERA

Worker ma za zadanie migrować tłumaczenia z serwera do klienta.

### Krok 1: Ekstrakcja kluczy z serwera
```bash
# Znajdź wszystkie użycia NPC_LIB.i18n.npcSay
grep -r "NPC_LIB.i18n.npcSay" data-otservbr-global/npc/ | \
  grep -oP '"[^"]+\.say_\d+"' | sort -u > keys_npc.txt

# Znajdź wszystkie klucze w i18n/*.json
find i18n/ -name "*.json" -exec cat {} \; | \
  jq -r 'keys[]' | sort -u > keys_server.txt
```

### Krok 2: Generowanie plików locales
```bash
# Skrypt Python: json_to_lua_locales.py
python3 tools/json_to_lua_locales.py \
  --input i18n/pl/npc.json \
  --output testyy/data/locales/game_i18n_pl.lua \
  --prefix "npc."
```

### Krok 3: Weryfikacja
```bash
# Sprawdź brakujące klucze
diff keys_server.txt keys_client.txt | grep "^<"
```

---

## ✅ CHECKLIST MIGRACJI

### Dla każdego NPC:
- [ ] Zidentyfikuj wszystkie `npcHandler:say()` i `NPC_LIB.i18n.npcSay()`
- [ ] Wyodrębnij klucze i18n używane w pliku
- [ ] Znajdź tłumaczenia w `i18n/*/npc.json` na serwerze
- [ ] Dodaj tłumaczenia do `game_i18n_*.lua` na kliencie
- [ ] Przetestuj w grze

### Dla głosów monster:
- [ ] Znajdź wszystkie `monsterType:addVoice()` z i18nKey
- [ ] Dodaj klucze do `game_i18n_*.lua` pod sekcją `mv.*`

### Dla głosów NPC:
- [ ] Znajdź wszystkie `npcType:addVoice()` z i18nKey  
- [ ] Dodaj klucze do `game_i18n_*.lua` pod sekcją `nv.*`

---

## 🔗 POWIĄZANE PLIKI

### Serwer (canary_test)
- `src/server/network/protocol/protocolgame.cpp` - sendLocalizedTextMessage, sendCreatureLocalizedSay
- `src/game/game.cpp` - internalCreatureLocalizedSay
- `data/libs/i18n_wrappers.lua` - NPC_LIB.i18n.npcSay
- `i18n/*/npc.json` - Słowniki NPC (źródło)

### Klient (testyy)
- `src/client/protocolgameparse.cpp` - parseLocalizedTextMessage, parseLocalizedCreatureSay
- `modules/client_locales/locales.lua` - funkcja tr()
- `data/locales/*.lua` - Słowniki UI
- `data/locales/game_i18n_*.lua` - Słowniki gry (CEL)
