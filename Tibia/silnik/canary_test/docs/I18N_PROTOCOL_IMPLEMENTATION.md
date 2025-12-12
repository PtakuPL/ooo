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
| 2 | **voiceBlock_t** | Głosy monster/NPC | P0 | ⏳ NASTĘPNE |
| 3 | **Monster names** | Nazwy potworów | P0 | ❌ TODO |
| 4 | **Item names** | Nazwy przedmiotów | P1 | ❌ TODO |
| 5 | **NPC names** | Nazwy NPC | P1 | ❌ TODO |
| 6 | **Spell names** | Nazwy zaklęć | P2 | ❌ TODO |
| 7 | **Combat messages** | "A dragon hits you" | P2 | ❌ TODO |
| 8 | **Descriptions** | Opisy (look at) | P3 | ❌ TODO |

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
| protocolgame.cpp | `src/server/network/protocol/` | sendLocalizedTextMessage() | ✅ ZAIMPLEMENTOWANO |
| protocolgame.hpp | `src/server/network/protocol/` | LocalizedTextMessage struct | ✅ ZAIMPLEMENTOWANO |
| player.cpp | `src/creatures/players/` | Metody sendTextMessage | ⏳ DO INTEGRACJI |
| player.hpp | `src/creatures/players/` | Deklaracje player | ⏳ DO INTEGRACJI |

### KLIENT (testyy)

| Plik | Ścieżka | Funkcja | Status |
|------|---------|---------|--------|
| protocolcodes.h | `src/client/` | GameServerLocalizedTextMessage = 188 | ✅ ZAIMPLEMENTOWANO |
| protocolgame.h | `src/client/` | parseLocalizedTextMessage() deklaracja | ✅ ZAIMPLEMENTOWANO |
| protocolgameparse.cpp | `src/client/` | parseLocalizedTextMessage() implementacja | ✅ ZAIMPLEMENTOWANO |
| locales.lua | `modules/client_locales/` | Funkcja tr() do tłumaczeń | ✅ JUŻ ISTNIEJE |
| *.lua | `data/locales/` | Słowniki tłumaczeń | ✅ JUŻ ISTNIEJĄ |

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
- [x] Użyć opcode 0xBC (188) dla nowych wiadomości
- [ ] Zintegrować z `player.cpp` (wywołania)

### ETAP 3: Modyfikacja klienta ✅ ZAKOŃCZONY
- [x] Dodać opcode `GameServerLocalizedTextMessage = 188` w `protocolcodes.h`
- [x] Dodać deklarację `parseLocalizedTextMessage()` w `protocolgame.h`
- [x] Dodać case w switch głównego parsera
- [x] Zaimplementować `parseLocalizedTextMessage()` z integracją `tr()`

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

### Serwer - sendLocalizedTextMessage

\`\`\`cpp
// Nowa struktura (protocolgame.hpp)
struct LocalizedTextMessage : public TextMessage {
    std::string i18nKey;  // Klucz tłumaczenia dla klienta
};

// Nowa metoda (protocolgame.cpp)
void ProtocolGame::sendLocalizedTextMessage(const LocalizedTextMessage &message);
// Opcode: 0xBC (188)
\`\`\`

### Klient - parseLocalizedTextMessage

\`\`\`cpp
// Nowy opcode (protocolcodes.h)
GameServerLocalizedTextMessage = 188

// Parser (protocolgameparse.cpp)
void ProtocolGame::parseLocalizedTextMessage(const InputMessagePtr& msg);
// Wywołuje g_lua.callGlobalField<std::string>("", "tr", i18nKey)
\`\`\`

### Format pakietu LocalizedTextMessage

\`\`\`
[0xBC:byte][type:byte][...dane wg typu...][text:string][i18nKey:string]
                                           ↑ fallback    ↑ klucz do tr()
\`\`\`

---

## ✅ POSTĘPY

| Data | Co zrobiono | Kto |
|------|-------------|-----|
| 2025-12-12 | Analiza protokołu serwera i klienta | AI + PtakuPL |
| 2025-12-12 | Implementacja LocalizedTextMessage na serwerze | AI |
| 2025-12-12 | Implementacja parseLocalizedTextMessage na kliencie | AI |
| | *Następne: integracja z player.cpp i testy* | |

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
