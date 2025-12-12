# 🔌 I18N Protocol Implementation - Plan Pracy

> **Dokument**: Implementacja protokołu i18n klient-serwer  
> **Data utworzenia**: 2025-12-12  
> **Data aktualizacji**: 2025-12-12  
> **Status**: 🔄 W TRAKCIE - FAZA 2  
> **Autor**: AI Assistant + PtakuPL

---

## 📋 PODSUMOWANIE

**Cel**: Zmodyfikować protokół komunikacji serwer↔klient tak, aby serwer wysyłał **krótkie klucze i18n** (1, 2, a, b, ^, 12...), a klient tłumaczył teksty lokalnie.

**Dlaczego to robimy:**
- **MEGA OPTYMALIZACJA** - klucze "1", "a" zamiast "Hello adventurer, welcome to..."
- Zero tłumaczeń server-side (bez mutex, bez cache)
- Mniejszy bandwidth (1-3 bajty vs 50-200 bajtów)
- Klient OTClient (testyy) już ma funkcję `tr()` i słowniki!

**Ryzyko:** Jeśli nie zadziała - cofamy wszystko i kombinujemy inaczej.

---

## 🎯 PEŁNA LISTA ELEMENTÓW DO ZLOKALIZOWANIA

| # | Element | Opis | Priorytet | Status |
|---|---------|------|-----------|--------|
| 1 | **sendTextMessage** | Wiadomości systemowe | P0 | ✅ ZROBIONE |
| 2 | **sendCreatureLocalizedSay** | Głosy monster/NPC | P0 | ✅ ZROBIONE |
| 3 | **voiceBlock_t** | Struktura z i18nKey | P0 | ✅ ZROBIONE |
| 4 | **Monster names** | Nazwy potworów | P0 | ❌ TODO |
| 5 | **Item names** | Nazwy przedmiotów | P1 | ❌ TODO |
| 6 | **NPC names** | Nazwy NPC | P1 | ❌ TODO |
| 7 | **Spell names** | Nazwy zaklęć | P2 | ❌ TODO |
| 8 | **Combat messages** | "A dragon hits you" | P2 | ❌ TODO |
| 9 | **Descriptions** | Opisy (look at) | P3 | ❌ TODO |

---

## 🔑 STRATEGIA KLUCZY

### Klucze krótkie (optymalizacja bandwidth)
```
Zamiast:  "npc.oracle.greeting_welcome_adventurer_to_tibia" (47 bajtów)
Używamy:  "1" lub "a" lub "^" (1 bajt)

Oszczędność: 46 bajtów × 1000 wiadomości = 46 KB per gracz!
```

### Mapowanie kluczy (na kliencie)
```lua
-- testyy/data/locales/pl.lua
locale.translation = {
    ["1"] = "Witaj wędrowcze! Zapraszam do Tibii...",
    ["2"] = "Żegnaj!",
    ["a"] = "Dragon",
    ["b"] = "Rat",
    -- ...
}
```

### Generowanie kluczy (skrypt)
```python
# Generuj krótkie klucze: 1-9, a-z, A-Z, kombinacje
keys = list("123456789") + list("abcdefghijklmnopqrstuvwxyz") + list("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
# Dla >62 elementów: "10", "11", "aa", "ab", ...
```

---

## 📂 STRUKTURA PLIKÓW

### SERWER (canary_test)

| Plik | Ścieżka | Funkcja | Status |
|------|---------|---------|--------|
| protocolgame.cpp | `src/server/network/protocol/` | sendLocalizedTextMessage(), sendCreatureLocalizedSay() | ✅ ZAIMPLEMENTOWANO |
| protocolgame.hpp | `src/server/network/protocol/` | LocalizedTextMessage struct, deklaracje | ✅ ZAIMPLEMENTOWANO |
| game.cpp | `src/game/` | internalCreatureLocalizedSay() | ✅ ZAIMPLEMENTOWANO |
| game.hpp | `src/game/` | Deklaracja funkcji | ✅ ZAIMPLEMENTOWANO |
| player.cpp | `src/creatures/players/` | sendCreatureLocalizedSay() | ✅ ZAIMPLEMENTOWANO |
| player.hpp | `src/creatures/players/` | Deklaracja | ✅ ZAIMPLEMENTOWANO |
| monster.cpp | `src/creatures/monsters/` | onThinkYell z i18nKey | ✅ ZAIMPLEMENTOWANO |
| npc.cpp | `src/creatures/npcs/` | onThinkYell z i18nKey | ✅ ZAIMPLEMENTOWANO |
| creatures_definitions.hpp | `src/creatures/` | voiceBlock_t.i18nKey | ✅ ZAIMPLEMENTOWANO |
| monster_type_functions.cpp | `src/lua/functions/creatures/monster/` | Lua addVoice(i18nKey) | ✅ ZAIMPLEMENTOWANO |
| npc_type_functions.cpp | `src/lua/functions/creatures/npc/` | Lua addVoice(i18nKey) | ✅ ZAIMPLEMENTOWANO |

### KLIENT (testyy)

| Plik | Ścieżka | Funkcja | Status |
|------|---------|---------|--------|
| protocolcodes.h | `src/client/` | GameServerLocalizedTextMessage = 188, GameServerLocalizedCreatureSay = 153 | ✅ ZAIMPLEMENTOWANO |
| protocolgame.h | `src/client/` | parseLocalizedTextMessage(), parseLocalizedCreatureSay() | ✅ ZAIMPLEMENTOWANO |
| protocolgameparse.cpp | `src/client/` | Implementacje parserów | ✅ ZAIMPLEMENTOWANO |
| locales.lua | `modules/client_locales/` | Funkcja tr() do tłumaczeń | ✅ JUŻ ISTNIEJE |
| *.lua | `data/locales/` | Słowniki tłumaczeń | ✅ JUŻ ISTNIEJĄ |

---

## 📡 OPCODES PROTOKOŁU I18N

| Opcode (hex) | Opcode (dec) | Nazwa | Kierunek | Opis |
|--------------|--------------|-------|----------|------|
| 0xBC | 188 | LocalizedTextMessage | S→C | Wiadomości systemowe z kluczem i18n |
| 0x99 | 153 | LocalizedCreatureSay | S→C | Głosy monster/NPC z kluczem i18n |

---

## 🔧 ETAPY IMPLEMENTACJI

### ETAP 1: Analiza protokołu ✅ ZAKOŃCZONY
- [x] Przeanalizować `sendTextMessage()` na serwerze
- [x] Przeanalizować `parseTextMessage()` na kliencie
- [x] Zidentyfikować opcode dla wiadomości tekstowych (0xB4 = 180)
- [x] Udokumentować obecny format pakietu

### ETAP 2: Modyfikacja serwera ✅ ZAKOŃCZONY
- [x] Dodać strukturę `LocalizedTextMessage` w `protocolgame.hpp`
- [x] Dodać metodę `sendLocalizedTextMessage()` w `protocolgame.cpp`
- [x] Dodać metodę `sendCreatureLocalizedSay()` w `protocolgame.cpp`
- [x] Dodać `internalCreatureLocalizedSay()` w `game.cpp/hpp`
- [x] Dodać `sendCreatureLocalizedSay()` w `player.cpp/hpp`
- [x] Rozszerzyć `voiceBlock_t` o pole `i18nKey`
- [x] Zaktualizować funkcje Lua `addVoice()` dla NPC i Monster
- [x] Zaktualizować `monster.cpp::onThinkYell()` do używania i18nKey
- [x] Zaktualizować `npc.cpp::onThinkYell()` do używania i18nKey

### ETAP 3: Modyfikacja klienta ✅ ZAKOŃCZONY
- [x] Dodać opcode `GameServerLocalizedTextMessage = 188` w `protocolcodes.h`
- [x] Dodać opcode `GameServerLocalizedCreatureSay = 153` w `protocolcodes.h`
- [x] Dodać deklarację `parseLocalizedTextMessage()` w `protocolgame.h`
- [x] Dodać deklarację `parseLocalizedCreatureSay()` w `protocolgame.h`
- [x] Dodać case w switch głównego parsera dla obu opcode'ów
- [x] Zaimplementować `parseLocalizedTextMessage()` z integracją `tr()`
- [x] Zaimplementować `parseLocalizedCreatureSay()` z integracją `tr()`

### ETAP 4: Migracja kluczy (DO ZROBIENIA)
- [ ] Przenieść klucze z `i18n/en/*.json` (serwer) do formatu klienta
- [ ] Stworzyć skrypt konwersji JSON → Lua locales
- [ ] Wygenerować pliki dla wszystkich języków

### ETAP 5: Testy i dokumentacja (DO ZROBIENIA)
- [ ] Test end-to-end: NPC mówi → klient wyświetla w języku gracza
- [ ] Test różnych języków klienta
- [ ] Dokumentacja dla deweloperów

---

## 📝 NOTATKI Z IMPLEMENTACJI

### 1. Serwer - sendLocalizedTextMessage (wiadomości systemowe)

\`\`\`cpp
// Nowa struktura (protocolgame.hpp)
struct LocalizedTextMessage : public TextMessage {
    std::string i18nKey;  // Klucz tłumaczenia dla klienta
};

// Nowa metoda (protocolgame.cpp)
void ProtocolGame::sendLocalizedTextMessage(const LocalizedTextMessage &message);
// Opcode: 0xBC (188)
\`\`\`

### 2. Serwer - sendCreatureLocalizedSay (głosy monster/NPC)

\`\`\`cpp
// Deklaracja (protocolgame.hpp)
void sendCreatureLocalizedSay(const std::shared_ptr<Creature> &creature, SpeakClasses type, 
                              const std::string &i18nKey, const std::string &fallbackText, 
                              const Position* pos = nullptr);
// Opcode: 0x99 (153)

// Użycie w monster.cpp/npc.cpp:
if (!voice.i18nKey.empty()) {
    g_game().internalCreatureLocalizedSay(creature, talkType, voice.i18nKey, voice.text, false);
} else {
    g_game().internalCreatureSay(creature, talkType, voice.text, false);
}
\`\`\`

### 3. Struktura voiceBlock_t

\`\`\`cpp
// creatures_definitions.hpp
struct voiceBlock_t {
    std::string text;      // Oryginalny tekst (fallback)
    bool yellText = false; // Czy krzyk
    std::string i18nKey;   // Klucz i18n dla klienta
};
\`\`\`

### 4. Lua API - addVoice()

\`\`\`lua
-- Nowy format z 6 parametrem (opcjonalny klucz i18n)
monsterType:addVoice("GRRRR!", 2000, 10, false, "mv_dragon_1")
npcType:addVoice("Hello traveler!", 5000, 5, false, "nv_shop_1")

-- getVoices() zwraca:
-- { text, interval, chance, yell, i18nKey }
\`\`\`

### 5. Klient - parseLocalizedCreatureSay

\`\`\`cpp
// protocolcodes.h
GameServerLocalizedCreatureSay = 153

// protocolgameparse.cpp
void ProtocolGame::parseLocalizedCreatureSay(const InputMessagePtr& msg) {
    // ... parsowanie jak parseTalk ...
    const auto& i18nKey = msg->getString();
    const auto& fallbackText = msg->getString();
    
    std::string translatedText = g_lua.callGlobalField<std::string>("", "tr", i18nKey);
    if (translatedText == i18nKey) translatedText = fallbackText;
    
    g_game.processTalk(name, level, mode, translatedText, 0, pos);
}
\`\`\`

### Format pakietów

**LocalizedTextMessage (0xBC / 188):**
\`\`\`
[0xBC:byte][type:byte][...dane wg typu...][text:string][i18nKey:string]
                                           ↑ fallback    ↑ klucz do tr()
\`\`\`

**LocalizedCreatureSay (0x99 / 153):**
\`\`\`
[0x99:byte][statementId:u32][name:string][suffix:byte][level:u16]
[talkType:byte][position:xyz][i18nKey:string][fallbackText:string]
                             ↑ klucz do tr()  ↑ dla starych klientów
\`\`\`

---

## ✅ POSTĘPY

| Data | Co zrobiono | Kto |
|------|-------------|-----|
| 2025-12-12 | Analiza protokołu serwera i klienta | AI + PtakuPL |
| 2025-12-12 | Implementacja LocalizedTextMessage na serwerze | AI |
| 2025-12-12 | Implementacja parseLocalizedTextMessage na kliencie | AI |
| 2025-12-12 | Implementacja sendCreatureLocalizedSay (serwer) | AI |
| 2025-12-12 | Implementacja parseLocalizedCreatureSay (klient) | AI |
| 2025-12-12 | Rozszerzenie voiceBlock_t o i18nKey | AI |
| 2025-12-12 | Aktualizacja onThinkYell w monster.cpp i npc.cpp | AI |
| 2025-12-12 | Aktualizacja funkcji Lua addVoice() | AI |
| | *Następne: Monster/Item/NPC names* | |

---

## ⚠️ PROBLEMY I ROZWIĄZANIA

### Problem: Stary klient bez obsługi nowego opcode
**Rozwiązanie**: Opcode 188 jest nieznany dla starych klientów - zostanie zignorowany. Użyj `sendTextMessage()` dla kompatybilności wstecznej.

### Problem: Brak tłumaczenia na kliencie
**Rozwiązanie**: Parser sprawdza czy `tr()` zwraca klucz - jeśli tak, używa fallback text.

---

## 📚 POWIĄZANE DOKUMENTY

- `docs/I18N_DEVELOPMENT_ROADMAP.md` - Główny roadmap projektu i18n
- `docs/I18N_SESSION_HANDOFF.md` - Status sesji i przekazanie
- `i18n/en/*.json` - Klucze i18n na serwerze (źródło)
- `testyy/data/locales/` - Słowniki na kliencie (cel)
