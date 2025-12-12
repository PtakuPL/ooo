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
| protocolgame.cpp | `src/server/network/protocol/` | Wysyłanie pakietów do klienta | ⏳ DO ANALIZY |
| protocolgame.hpp | `src/server/network/protocol/` | Deklaracje metod protokołu | ⏳ DO ANALIZY |
| player.cpp | `src/creatures/players/` | Metody sendTextMessage | ⏳ DO ANALIZY |
| player.hpp | `src/creatures/players/` | Deklaracje player | ⏳ DO ANALIZY |

### KLIENT (testyy)

| Plik | Ścieżka | Funkcja | Status |
|------|---------|---------|--------|
| protocolgame.cpp | `testyy/src/client/` | Parsowanie pakietów z serwera | ⏳ DO ANALIZY |
| keyboard.lua | `testyy/modules/corelib/` | Funkcja tr() do tłumaczeń | ✅ JUŻ ISTNIEJE |
| locales/*.lua | `testyy/data/locales/` | Słowniki tłumaczeń | ✅ JUŻ ISTNIEJĄ |

---

## 🔧 ETAPY IMPLEMENTACJI

### ETAP 1: Analiza protokołu (AKTUALNY)
- [ ] Przeanalizować `sendTextMessage()` na serwerze
- [ ] Przeanalizować `parseTextMessage()` na kliencie
- [ ] Zidentyfikować opcode dla wiadomości tekstowych
- [ ] Udokumentować obecny format pakietu

### ETAP 2: Modyfikacja serwera
- [ ] Dodać nową metodę `sendLocalizedTextMessage(type, text, i18nKey)`
- [ ] Rozszerzyć pakiet o pole `hasI18nKey` + `i18nKey`
- [ ] Przetestować że stary klient nadal działa (kompatybilność)
- [ ] Zmodyfikować miejsca które wysyłają zlokalizowane teksty

### ETAP 3: Modyfikacja klienta
- [ ] Rozszerzyć `parseTextMessage()` o odczyt `i18nKey`
- [ ] Zintegrować z funkcją `tr()` z `keyboard.lua`
- [ ] Dodać fallback gdy brak tłumaczenia
- [ ] Przetestować wyświetlanie tłumaczonych tekstów

### ETAP 4: Migracja kluczy
- [ ] Przenieść klucze z `i18n/en/*.json` (serwer) do formatu klienta
- [ ] Stworzyć skrypt konwersji JSON → Lua locales
- [ ] Wygenerować pliki dla wszystkich języków

### ETAP 5: Testy i dokumentacja
- [ ] Test end-to-end: NPC mówi → klient wyświetla w języku gracza
- [ ] Test różnych języków klienta
- [ ] Dokumentacja dla deweloperów

---

## 📝 NOTATKI Z ANALIZY

### Serwer - sendTextMessage

*Do uzupełnienia po analizie plików*

```cpp
// Obecna sygnatura (do potwierdzenia):
void ProtocolGame::sendTextMessage(const TextMessage& message);
```

### Klient - parseTextMessage

*Do uzupełnienia po analizie plików*

```cpp
// Obecna sygnatura (do potwierdzenia):
void ProtocolGame::parseTextMessage(const InputMessagePtr& msg);
```

### Format pakietu tekstowego

*Do uzupełnienia po analizie*

```
Obecny format:
[opcode:byte][type:byte][text:string]

Proponowany format:
[opcode:byte][type:byte][text:string][hasI18nKey:byte][i18nKey:string?]
```

---

## ✅ POSTĘPY

| Data | Co zrobiono | Kto |
|------|-------------|-----|
| 2025-12-12 | Utworzono plan pracy i dokumentację | AI + PtakuPL |
| | *Następne kroki...* | |

---

## ⚠️ PROBLEMY I ROZWIĄZANIA

*Sekcja na problemy napotkane podczas implementacji*

---

## 📚 POWIĄZANE DOKUMENTY

- `docs/I18N_DEVELOPMENT_ROADMAP.md` - Główny roadmap projektu i18n
- `docs/I18N_SESSION_HANDOFF.md` - Status sesji i przekazanie
- `i18n/en/*.json` - Klucze i18n na serwerze (źródło)
- `testyy/data/locales/` - Słowniki na kliencie (cel)
