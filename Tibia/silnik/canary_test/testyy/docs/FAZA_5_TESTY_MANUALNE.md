# FAZA 5 - Testy manualne TTF/Unicode

## Data: 15 grudnia 2025
## Status: 🟡 GOTOWE DO WYKONANIA

---

## PODSUMOWANIE IMPLEMENTACJI

### ✅ Zakończone fazy:

| Faza | Opis | Status |
|------|------|--------|
| **FAZA 0** | Naprawić ładowanie TTF | ✅ DONE |
| **FAZA 1** | Refaktor UITextEdit na codepoints | ✅ DONE |
| **FAZA 2A** | UI Framework TTF branches | ✅ DONE |
| **FAZA 2B** | Client-side text rendering | ✅ DONE |
| **FAZA 3** | BitmapFont refactor | ⏭️ POMINIĘTE (używamy TTF) |
| **FAZA 4** | Konfiguracja fontów | ✅ DONE |
| **FAZA 5** | Testowanie | 🟡 W TRAKCIE |

---

## TESTY DO WYKONANIA

### 📝 T1-T4: Podstawowe wyświetlanie tekstu

| ID | Komponent | Test | Oczekiwany wynik |
|----|-----------|------|------------------|
| **T1** | UILabel | "Zapamiętaj hasło" | Polskie znaki wyświetlone poprawnie |
| **T2** | UIButton | "Połącz" z "ó" | Tekst na przycisku z polskimi znakami |
| **T3** | UITextEdit | Wpisz "żółć" + backspace | Każdy znak usuwany osobno, nie bajt po bajcie |
| **T4** | StaticText | NPC mówi "Cześć!" | Poprawne wyświetlanie w dymku |

### 🔢 T5-T6: Animacje i postacie

| ID | Komponent | Test | Oczekiwany wynik |
|----|-----------|------|------------------|
| **T5** | AnimatedText | Damage numbers | Cyfry działają normalnie (bez zmian) |
| **T6** | Creature | Nazwa NPC "Żółw" | Nazwa nad głową z polskimi znakami |

### 💬 T7: Chat

| ID | Komponent | Test | Oczekiwany wynik |
|----|-----------|------|------------------|
| **T7** | Chat | Napisz "Witaj świecie!" | Polskie znaki w wiadomości |

### 🌍 T8: RTL (Right-to-Left)

| ID | Komponent | Test | Oczekiwany wynik |
|----|-----------|------|------------------|
| **T8** | Dowolny | Arabic: "مرحبا" | Tekst czytany od prawej do lewej |

### 📄 T9-T10: Multiline i skalowanie

| ID | Komponent | Test | Oczekiwany wynik |
|----|-----------|------|------------------|
| **T9** | UILabel | "Linia 1\nLinia 2" | Dwie linie tekstu, poprawna wysokość |
| **T10** | UIWidget | font-scale: 2.0 | Tekst powiększony 2x |

### 📏 T11-T12: Zawijanie i klikanie

| ID | Komponent | Test | Oczekiwany wynik |
|----|-----------|------|------------------|
| **T11** | UIWidget | Długi tekst w wąskim widżecie | Tekst zawinięty po słowach, nie w środku znaku |
| **T12** | UITextEdit | Kliknij w "żółć" | Kursor ustawiony między właściwymi znakami |

---

## JAK TESTOWAĆ

### Przygotowanie:

1. Skompiluj projekt:
   ```bash
   cd testyy
   ./recompile.sh
   ```

2. Uruchom klienta:
   ```bash
   ./otclient
   ```

### Scenariusze testowe:

#### T3 - UITextEdit (kursor/backspace):
1. Otwórz pole tekstowe (np. login)
2. Wpisz "żółć"
3. Naciśnij backspace - powinien usunąć "ć" (nie połowę bajtu)
4. Kontynuuj usuwanie - każdy znak osobno

#### T7 - Chat:
1. Połącz się z serwerem
2. Otwórz chat
3. Wpisz "Witaj świecie! Żółć ąęść"
4. Sprawdź czy tekst jest poprawny

#### T11 - Zawijanie tekstu:
1. Znajdź wąski widżet z długim tekstem
2. Sprawdź czy tekst zawija się po słowach
3. Sprawdź czy polskie znaki nie są rozdzielone

---

## ZGŁASZANIE PROBLEMÓW

Jeśli test nie przeszedł:

1. **Opisz test**: numer (np. T3)
2. **Co zrobiłeś**: krokowo
3. **Co oczekiwałeś**: poprawne zachowanie
4. **Co się stało**: rzeczywiste zachowanie
5. **Screenshot**: jeśli możliwe

---

## WYNIKI TESTÓW

| Test | Data | Wynik | Uwagi |
|------|------|-------|-------|
| T1 | - | ⬜ | |
| T2 | - | ⬜ | |
| T3 | - | ⬜ | |
| T4 | - | ⬜ | |
| T5 | - | ⬜ | |
| T6 | - | ⬜ | |
| T7 | - | ⬜ | |
| T8 | - | ⬜ | |
| T9 | - | ⬜ | |
| T10 | - | ⬜ | |
| T11 | - | ⬜ | |
| T12 | - | ⬜ | |

---

## PO ZAKOŃCZENIU TESTÓW

Gdy wszystkie testy przejdą:

1. Zaktualizuj tę tabelę z wynikami
2. Zmień status FAZA 5 na ✅ DONE w FONT_UNICODE_MIGRATION.md
3. Commit:
   ```bash
   git add .
   git commit -m "TTF/Unicode implementation complete - all phases done"
   git push
   ```

---

## PLIKI DOKUMENTACJI

- [FONT_UNICODE_MIGRATION.md](./FONT_UNICODE_MIGRATION.md) - Główna dokumentacja migracji
- [FAZA_2_CHECKLIST.md](./FAZA_2_CHECKLIST.md) - Checklist FAZA 2
- [TTF_UNICODE_SUPPORT.md](../../docs/TTF_UNICODE_SUPPORT.md) - Architektura systemu
- [FAZA_2_WYMAGANE_NAPRAWY.md](../../docs/FAZA_2_WYMAGANE_NAPRAWY.md) - Lista wszystkich napraw
