# PLAN NAPRAWCZY v2 — System i18n OTClient Redemption
**Data:** 2026-02-15 (aktualizacja: 2026-02-16)  
**Status:** W TRAKCIE REALIZACJI — Zadania 1-4, 6-9 WYKONANE, Zadanie 5 wymaga testu użytkownika  
**Build Windows:** PRZESZEDŁ POMYŚLNIE ✅

---

Do naprawienia , isntalka po wyłączeniu jej nie tworzy pliku log a wcześniej tworzyła
Pamiętaj aby aktualizować dokumentację po wykonanych zadaniach że one są wykonane i było to widoczne , lub że są w trakcie.
Jeśli pod czas pracy znajdziesz kolejne zadania do zrobienia to je tutaj dopisz na póżniej. 

## PEŁNA KATALOGACJA BŁĘDÓW ZE SCREENA (15 pozycji)

### BŁĘDY KRYTYCZNE (powodują kaskadę):

| # | Typ | Komunikat | Plik źródłowy | Status |
|---|-----|-----------|---------------|--------|
| 1 | ERROR | `LUA ERROR: /locales/de.lua:315: unexpected symbol near '\'` | de.lua:315 | ✅ **NAPRAWIONY** (sklejone wpisy rozdzielone) |
| 2 | STACK | `dofile → installLocales(locales.lua:252) → init(locales.lua:88) → client_locales.otmod:8 → ensureModuleLoaded → init.lua:100` | locales.lua | ℹ️ Kaskada z #1 |
| 3 | ERROR | `Module 'client_locales': LUA ERROR:` | locales.otmod | ℹ️ Powtórzenie #1 — moduł client_locales NIE ZAŁADOWAŁ SIĘ |
| 4 | ERROR | `LUA ERROR: /locales/de.lua:315: unexpected symbol near '\'` | de.lua:315 | ℹ️ Powtórzenie #1 |
| 5 | STACK | Ten sam stack trace co #2 | - | ℹ️ Powtórzenie |

### BŁĘDY KASKADOWE (wynikają z #1):

| # | Typ | Komunikat | Plik źródłowy | Status |
|---|-----|-----------|---------------|--------|
| 6 | ERROR | `/corelib/ui/uitabbar.lua:115: attempt to index local 'tab' (a nil value)` | uitabbar.lua:115 | ✅ **NAPRAWIONY** — nil-check dodany w selectTab() (Zadanie 3) |
| 7 | STACK | `__index → selectTab(uitabbar.lua:115) → initInterface(market.lua:922) → init(market.lua:1125) → game_market.otmod:8 → init.lua:104` | market.lua | ℹ️ Stack trace |
| 8 | ERROR | `Module 'game_market': LUA ERROR:` | game_market.otmod | ✅ **NAPRAWIONY** — kaskada z #6, nil-check naprawiony |
| 9 | ERROR | `/corelib/ui/uitabbar.lua:115: attempt to index local 'tab' (a nil value)` | uitabbar.lua:115 | ℹ️ Powtórzenie #6 |
| 10 | STACK | Ten sam stack trace co #7 | - | ℹ️ Powtórzenie |

### INFORMACYJNE / RENDERING:

| # | Typ | Komunikat | Plik źródłowy | Status |
|---|-----|-----------|---------------|--------|
| 11 | INFO | `Startup done :)` | init.lua | ✅ OK — klient startuje |
| 12 | INFO | `BitmapFont::drawText: using TTF path (first time). rect=(1386,733 150x68)` | C++ TTF engine | ℹ️ Pierwszy render TTF |
| 13 | INFO | `TTFFont::drawText: first call OK (quads=22, x=1387.7656, y=746)` | C++ TTF engine | ℹ️ Render OK |
| 14 | WARNING | `TTFont::drawText: submitting vertices=132 with INVALID texture (ptr=true, id=0) -> text will not render` | C++ TTF engine | 🔴 TTF RENDERING BUG |

### OBJAWY W UI (surowe klucze zamiast tekstu):

| # | Klucz wyświetlany | Oczekiwany tekst (EN) | Moduł |
|---|-------------------|----------------------|-------|
| U1 | `otclient_modules.topmenu_otui.tr_1` | "players online" | topmenu |
| U2 | `otclient_modules.entergame.tr_17` | "Journey Onwards" | entergame |
| U3 | `otclient_modules.entergame.tr_16` | (email label text) | entergame |
| U4 | `otclient_modules.entergame_otui.tr_13` | (UI element text) | entergame OTUI |
| U5 | `otclient_modules.entergame_otui.tr_12` | (UI element text) | entergame OTUI |
| U6 | `otclient_modules.entergame_otui.tr_11` | (UI element text) | entergame OTUI |
| U7 | `otclient_modules.entergame_otui.tr_9` | (UI element text) | entergame OTUI |
| U8 | `otclient_modules.entergame_otui.tr_8` | (UI element text) | entergame OTUI |
| U9 | `otclient_modules.entergame.tr_15` | "Remember email" | entergame |
| U10 | `otclient_modules.entergame_otui.tr_5` | (checkbox/button text) | entergame OTUI |
| U11 | `otclient_modules.bottommenu_otui.tr_*` | "Boss", "Creature", etc. | bottommenu |
| U12 | `otclient_modules.topmenu_otui.tr_3` | (topmenu element) | topmenu |

---

## GŁÓWNA PRZYCZYNA

**Błąd #1** (`de.lua:315: unexpected symbol near '\'`) powoduje, że CAŁA funkcja `installLocales()` przerywa się z błędem. Powód: `installLocales()` iteruje po plikach w `/locales/` i wywołuje `dofile()` dla każdego. `de.lua` jest ładowany PRZED `en.lua` (alfabetycznie). Gdy `de.lua` rzuca błąd:
- `dofile()` propaguje wyjątek do `installLocales()`
- `installLocales()` przerywa się (NIE łapie błędu!)
- Żadne locale (EN, JA, PL itp.) NIE SĄ załadowane po de.lua
- `init()` kontynuuje (bo `installLocales` jest wywoływane bez pcall)
- `setLocale('ja')` nie może ustawić locale (bo nie są zainstalowane)
- `tr()` zwraca surowy klucz (bo `currentLocale` jest nil lub pusty)

**Kaskada game_market (#6-#10):** Moduł game_market używa `selectTab()` na elementach UI które zależą od tłumaczeń. Bez załadowanego systemu i18n, pewne widgety nie tworzą się prawidłowo, co powoduje nil tab.

**TTF Warning (#14):** Tekstura fontu nie jest zainicjalizowana prawidłowo. To MOŻE być osobny bug C++, ale też MOŻE wynikać z tego, że system i18n nie działa — renderowane są długie klucze zamiast krótkich tłumaczeń, co może powodować inny flow w TTF cache.

---

## POPRAWKI JUŻ ZASTOSOWANE (2026-02-15)

| # | Poprawka | Pliki | Status |
|---|---------|-------|--------|
| P1 | Odbudowa game_i18n_*.lua (53k→5.8k linii) | 53 plików | ✅ Na C: i WSL |
| P2 | Stuby game_i18n_*_compact.lua | 55 plików | ✅ Na C: i WSL |
| P3 | Vararg fix w applyFormat() | locales.lua | ✅ Na C: i WSL |
| P4 | Naprawka złamanych stringów w de.lua (poprzednia) | de.lua | ✅ Na C: i WSL |
| P5 | Scalenie JSON-ów klienckich | 53 plików _client_all.json | ✅ Na C: i WSL |
| **P6** | **Rozdzielenie sklejonych wpisów w de.lua (L315+L1215)** | **de.lua** | **✅ Właśnie naprawione!** |

---

## PLAN NAPRAWCZY — 10 ZADAŃ

### ZADANIE 1: ✅ WYKONANE — Naprawić de.lua:315 (błąd #1)
**Status:** ZROBIONE  
**Opis:** Dwa wpisy tablicy Lua były sklejone literalnym `\n` zamiast prawdziwego newline.  
**Co zrobiono:** Rozdzielono na obu lokalizacjach (C: i WSL).

---

### ZADANIE 2: ✅ WYKONANE — Wzmocnić installLocales() — odporność na błędy  
**Priorytet:** KRYTYCZNY  
**Status:** ZROBIONE (2026-02-16)  
**Dotyczy błędów:** #1-#5 (zabezpieczenie na przyszłość)

**Co zrobiono:**
1. ✅ Zamieniono `dofile(directory .. '/' .. file)` na `pcall(dofile, directory .. '/' .. file)` w `installLocales()`
2. ✅ Dodano logowanie: `pwarning('[i18n] Failed to load locale: ' .. file .. ': ' .. tostring(err))`
3. ✅ Pętla kontynuuje ładowanie kolejnych plików mimo błędu
4. ✅ Zsynchronizowano na C: i WSL

---

### ZADANIE 3: ✅ WYKONANE — Naprawić problem game_market / uitabbar.lua:115
**Priorytet:** WYSOKI  
**Status:** ZROBIONE (2026-02-16)  
**Dotyczy błędów:** #6-#10

**Co zrobiono:**
1. ✅ Dodano nil-check na początku `selectTab()`: `if not tab then pwarning(...) return end`
2. ✅ Zabezpieczenie przed kaskadą niezależnie od stanu i18n
3. ✅ Zsynchronizowano na C: i WSL

---

### ZADANIE 4: ✅ WYKONANE — Zbadać TTF rendering warning + walidacja tekstur
**Priorytet:** ŚREDNI  
**Status:** ZROBIONE (2026-02-16)  
**Dotyczy błędów:** #14

**Co zrobiono:**
1. ✅ Zbadano `TTFFont::drawText()` w kodzie C++ — warning NIE ISTNIEJE w bieżącym źródle (pochodzi z innego builda)
2. ✅ Dodano walidację tekstur przed wysyłką do draw pool — skip batch jeśli `texture->getId() == 0`
3. ✅ Dodano logowanie: `TTFFont::drawText: skipping batch with N vertices — texture invalid`
4. ℹ️ Wymaga rekompilacji C++ aby weryfikować efekt
5. ℹ️ Warning może zniknąć po naprawie i18n (krótsze teksty = mniej glyphów = mniejsze szanse na atlas overflow)

**Oczekiwany efekt:** Tekst renderuje się prawidłowo, brak WARNING w konsoli.

---

### ZADANIE 5: Naprawić brak wyświetlania tłumaczeń (surowe klucze U1-U12)
**Priorytet:** KRYTYCZNY  
**Dotyczy:** Wszystkie surowe klucze widoczne w UI

**Podzadania:**
1. **5.1** — Po naprawie de.lua sprawdzić: czy klient teraz wyświetla tłumaczenia?
2. **5.2** — Jeśli NIE — dodać diagnostykę do `tr()`: logować pierwsze 5 miss-ów z liczbą translacji w locale
3. **5.3** — Sprawdzić czy `loadGameI18nForLocale()` faktycznie merguje translations — dodać debug count before/after
4. **5.4** — Sprawdzić czy config ma `locale: ja` → ja.lua musi mieć wpis `installLocale()` → game_i18n_ja musi być ładowany
5. **5.5** — Zweryfikować że klucz `otclient_modules.entergame.tr_17` istnieje w game_i18n_ja.lua (POTWIERDZONE: istnieje, wartość `[EN] Journey Onwards`)
6. **5.6** — Jeśli problem wynika z kolejności ładowania: en.lua (który jest bazowy, translation={}) jest ładowany PO de.lua (który failuje). Naprawa de.lua powinna rozwiązać problem.

**Oczekiwany efekt:** Wszystkie 12 surowych kluczy (U1-U12) wyświetla się jako przetłumaczony tekst.

---

### ZADANIE 6: ✅ WYKONANE — Stworzyć brakującą ikonę language button  
**Priorytet:** WYSOKI  
**Status:** ZROBIONE (2026-02-16)  
**Dotyczy:** Brak przycisku języka w topmenu

**Co zrobiono:**
1. ✅ Sprawdzono istniejące ikony topbuttons — wszystkie 16x16 RGBA PNG
2. ✅ Stworzono `language.png` (16x16 RGBA) — ikona globu z kontynentami + południkiem/równikiem
3. ✅ Skopiowano do `data/images/topbuttons/language.png` na C: i WSL

---

### ZADANIE 7: ✅ WYKONANE — Usunąć redundantne dofile z plików bazowych lokali
**Priorytet:** ŚREDNI  
**Status:** ZROBIONE (2026-02-16)  
**Dotyczy:** Redundancja ładowania + potencjalne błędy

**Co zrobiono:**
1. ✅ Usunięto `dofile('game_i18n_en')` i `dofile('game_i18n_en_compact')` z en.lua
2. ✅ Usunięto `dofile('game_i18n_pl')` i `dofile('game_i18n_pl_compact')` z pl.lua
3. ✅ Sprawdzono de, es, fr, pt, ru — brak dofile (OK)
4. ✅ ja.lua nie miał dofile (dobry wzór)
5. ✅ Flaga `__gameI18nLoaded` zapobiega podwójnemu ładowaniu
6. ✅ Zsynchronizowano na C: i WSL

---

### ZADANIE 8: ✅ WYKONANE — Oczyścić artefakty z katalogu modułu
**Priorytet:** NISKI  
**Status:** ZROBIONE (2026-02-16)

**Co zrobiono:**
1. ✅ Usunięto `locales1.lua` z `modules/client_locales/` (stara wersja 239 linii)
2. ✅ Usunięto `locales_bridge_openLanguagePicker.lua` (27 linii, już niepotrzebny)
3. ✅ Usunięto 5 plików artefaktów z `data/locales/`:
   - `de.lua.bak_concat_fix`
   - `pl.lua.corrupted_backup`
   - `pl.lua.utf8.bak`
   - `pl.lua.utf8.bak2`
   - `pl_upstream.lua`
4. ✅ Oczyszczono na C: i WSL

---

### ZADANIE 9: ✅ WYKONANE — Uzupełnić spójność flag / lokali
**Priorytet:** NISKI  
**Status:** ZROBIONE (2026-02-16)

**Co zrobiono:**
1. ✅ Znaleziono `sv.lua` w `disabled/` — skopiowano do aktywnych lokali
2. ✅ Naprawiono brakujący `end` na końcu pliku sv.lua (plik był obcięty)
3. ✅ Teraz 9 flag = 9 aktywnych lokali (de, en, es, fr, ja, pl, pt, ru, sv)
4. ✅ Zsynchronizowano na C: i WSL

---

### ZADANIE 10: Diagnostyka i dokumentacja końcowa
**Priorytet:** WYMAGANE PO NAPRAWACH

**Podzadania:**
1. **10.1** — Uruchomić klient z `locale: en` (zresetować w config.otml)
2. **10.2** — Sprawdzić konsolę — ZERO RED ERRORS oczekiwane
3. **10.3** — Sprawdzić UI — tłumaczenia angielskie widoczne zamiast kluczy
4. **10.4** — Ctrl+L — language picker otwiera się
5. **10.5** — Zmienić na polski → teksty się zmieniają
6. **10.6** — Zmienić na japoński → teksty japońskie
7. **10.7** — Sprawdzić topmenu → przycisk języka widoczny
8. **10.8** — Sprawdzić game_market → bez błędów uitabbar
9. **10.9** — Sprawdzić TTF warning → zniknął lub utrzymuje się
10. **10.10** — Zapisać wyniki do dokumentacji + odnotować sukces buildu Windows

---

## KOLEJNOŚĆ WYKONANIA

```
FAZA 0 — ✅ ZROBIONE: Naprawa de.lua:315 (Zadanie 1)
                ↓
FAZA 1 — ✅ ZROBIONE: Wzmocnić installLocales z pcall (Zadanie 2)
             + Test: uruchomić klient, czy i18n działa (Zadanie 5.1) — CZEKA NA TEST UŻYTKOWNIKA
                ↓
FAZA 2 — ✅ ZROBIONE: game_market/uitabbar (Zadanie 3)
             + TTF rendering (Zadanie 4) — walidacja dodana, wymaga rekompilacji
             + Ikona language button (Zadanie 6) — stworzona
                ↓
FAZA 3 — ✅ ZROBIONE: Usunięcie redundancji (Zadanie 7)
             + Artefakty (Zadanie 8) + Flagi (Zadanie 9)
                ↓
FAZA 4 — CZEKA: Pełny test + Dokumentacja (Zadanie 10) — wymaga uruchomienia klienta
```

---

## MAPOWANIE BŁĘDÓW → ZADAŃ

| Błąd # | Opis | Zadanie naprawcze | Status |
|--------|------|-------------------|--------|
| 1-5 | de.lua:315 unexpected symbol + kaskada client_locales | Zadanie 1 + 2 | ✅ |
| 6-10 | uitabbar.lua:115 tab=nil + kaskada game_market | Zadanie 3 | ✅ |
| 14 | TTFont INVALID texture, text will not render | Zadanie 4 | ✅ (wymaga rekompilacji) |
| U1-U12 | Surowe klucze w UI (12 instancji) | Zadanie 5 | ⏳ Test użytkownika |
| — | Brak ikony language button | Zadanie 6 | ✅ |
| — | Redundantne dofile w lokali | Zadanie 7 | ✅ |
| — | Pliki artefaktów | Zadanie 8 | ✅ |
| — | Niespójność flagi/locale | Zadanie 9 | ✅ |

---

## RYZYKO I UWAGI

1. **Po naprawie de.lua (Zadanie 1)** — istnieje DUŻA szansa, że błędy #6-#10 i U1-U12 znikną automatycznie (kaskada)
2. Jeśli `game_market` ma NIEZALEŻNY bug w uitabbar.lua:115 — trzeba dodać nil-check (Zadanie 3.4) — ✅ DODANO
3. TTF warning (#14) MOŻE być niezależny od i18n — wymaga testów — ✅ WALIDACJA DODANA
4. Pliki na C: i WSL MUSZĄ być synchronizowane — każda zmiana na obu lokalizacjach
5. Config.otml ma `locale: ja` — do testów najpierw zmienić na `en` (łatwiej debugować)

---

## DODATKOWE ZADANIE: Brak pliku log po wyłączeniu klienta

**Zgłoszone przez:** Użytkownik  
**Status:** ⏳ Do zbadania  
**Opis:** "Instalka po wyłączeniu jej nie tworzy pliku log a wcześniej tworzyła"  
**Notatka:** Wymaga zbadania konfiguracji logowania w kodzie C++ i ustawień klienta.

---

*Dokument wymaga zatwierdzenia przed rozpoczęciem Fazy 1-4.*  
*Faza 0 (Zadanie 1) już wykonana — naprawa de.lua.*
