# 🔌 I18N Protocol Implementation - Plan Pracy

> **Dokument**: Implementacja protokołu i18n klient-serwer  
> **Data utworzenia**: 2025-12-12  
> **Status**: 🔄 W TRAKCIE  
> **Autor**: AI Assistant + PtakuPL

---

## 📋 PODSUMOWANIE

**Cel**: Zmodyfikować protokół komunikacji serwer↔klient tak, aby serwer wysyłał klucze i18n, a klient tłumaczył teksty lokalnie.

**Dlaczego to robimy:**
- Optymalizacja serwera (zero tłumaczeń server-side)
- Mniejszy bandwidth (klucze krótsze od tekstów)
- Klient OTClient (testyy) już ma funkcję `tr()` i słowniki!

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
