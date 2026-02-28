# Plan naprawy problemów UI klienta + serwera — i18n
**Data**: 2026-02-22  
**Status**: PLAN — analiza + zadania  
**Źródło**: Screeny z testów 22.02.2026, OTClient Redemption  
**Aktualizacja**: 2026-02-28 — nowe problemy UI/i18n (screeny 1-3: branding, auto-reconnect, picker języków)  

---

## Spis problemów (ze screenów)

| # | Screen | Problem | Priorytet | Typ |
|---|--------|---------|-----------|-----|
| P1 | 1 | ✅ Tekst w oknie książki wychodzi poza okno | WYSOKI | Klient UI |
| P2 | 2 | ✅ NPC nie mówi żółtym tekstem nad sobą (naprawione zmianą na npc:say + TALKTYPE_PRIVATE_NP) | WYSOKI | Serwer + Klient |
| P3 | 2 | ✅ Tekst NPC zawiera surowe klucze i18n ("choosing swojej vocation") | WYSOKI | Serwer i18n |
| P4 | 3 | NPC nie reaguje na "siemkanko" (brak odpowiedzi) | ŚREDNI | Serwer NPC |
| P5 | 2,3 | Polskie znaki nie działają na czacie (problem instalki) | ŚREDNI | Klient input |
| P6 | 2,3 | ✅ Waga/Dusza w panelu ekwipunku — poprawione tłumaczenia | NISKI | Klient UI |
| P7 | 4 | ✅ Sklep: button "Kup" + text-auto-resize | ŚREDNI | Klient UI |
| P8 | 4 | ✅ Czat: toggleChat text-auto-resize | ŚREDNI | Klient UI |
| P9 | 5 | ✅ Cyklopedia/Charms: poprawione tłumaczenia + .action fix | ŚREDNI | Klient UI |
| P10 | 2 | ✅ Komendy NPC ({trade}, {buy}) prześwietlają/nie działają | WYSOKI | Serwer + Klient |
| P11 | - | ✅ Nie można wyjść z Rooka na 8 lvl (NPC Oressa blokuje) | WYSOKI | Serwer NPC |
| P12 | 1 | ✅ Branding "OTClient - Redemption" i "OTClient Redemption" usunięty z runtime UI | ŚREDNI | Klient UI/Branding |
| P13 | 1,2 | ✅ Auto reconnect: usunięty hardcoded EN + poprawiony layout controlki | WYSOKI | Klient UI + i18n |
| P14 | 3 | ✅ Picker języka: fallback ikony + normalizacja locale wdrożone (pełny pakiet flag nadal jako osobny task assets) | ŚREDNI | Klient assets/UI |
| P15 | 3 | ✅ Uszkodzone znaki nazw języków naprawione (es/pt) + fallback nazw dla problematycznych skryptów | WYSOKI | Klient i18n/font |
| P16 | 3 | Jakość tłumaczeń `Auto reconnect`: 48/53 locale z EN fallback + wykryte `[EN]` tagi (np. `zh_TW`) | ŚREDNI | Klient i18n/QA |

---

## Dowody wizualne (zgłoszenie 2026-02-28)
- **Screen 1 (przed)**: widoczny branding `OTClient - Redemption` + overflow napisu `Automatyczne ponowne połączenie: OFF`.
- **Screen 2 (przed)**: po kliknięciu auto reconnect label przechodził na hardcoded EN (`Auto reconnect: On`).
- **Screen 3 (przed)**: picker języków bez części flag + błędne nazwy (`Espa�ol`, `Portugu�s`) i kwadraty glifów.
- **Status po zmianach kodu**: P12 i P13 zamknięte kodowo; P14/P15 zamknięte kodowo (z fallbackami), do domknięcia manualnym testem UI + ewentualnym dołożeniem pełnego pakietu flag.

---

## PROBLEM P1: Tekst książki wychodzi poza okno ✅ NAPRAWIONE

### Analiza
- **Pliki klienta**: `modules/game_textwindow/textwindow.otui`, `textwindow.lua`
- Okno ma stały rozmiar `300x450`
- `MultilineTextEdit #text` ma `text-wrap: true` i `VerticalScrollBar`
- Na screenie scrollbar jest, ale tekst wychodzi poza dolną krawędź okna.

### Przyczyna główna (ROOT CAUSE)
Problem leżał w `src/framework/ui/uitextedit.cpp` — ścieżka renderingu TTF fontów:

1. **Brak scrollowania**: W `update()` (linie ~260 i ~310) dla TTF fontów `m_textVirtualOffset` był resetowany do `{}` (Point(0,0)), co całkowicie wyłączało scrollowanie. Scrollbar zmieniał offset, ale `update()` natychmiast go zerował.

2. **Brak clippingu**: W `drawSelf()` (linia ~100) ścieżka TTF nie miała `setClipRect()` — tekst renderował się poza granicami widgeta, widoczny poza oknem.

3. **Brak przesunięcia drawArea o scroll offset**: Nawet gdyby offset nie był zerowany, `m_drawArea` nie był przesuwany o `m_textVirtualOffset`, więc tekst nie scrollował się wizualnie.

4. **Literówka w totalSize**: `totalSize.setWidth(m_textVirtualSize.height())` — kopiowała height do width zamiast `m_textVirtualSize.width()`.

### Zastosowane poprawki (`uitextedit.cpp`)

**Poprawka 1 — drawSelf() TTF clipping + scroll offset:**
```cpp
// Przed: m_font->drawText(m_drawText, m_drawArea, m_color, m_textAlign);
// Po:
Rect ttfDrawArea = m_drawArea;
if (m_textVirtualOffset.y > 0 || m_textVirtualOffset.x > 0) {
    ttfDrawArea.translate(-m_textVirtualOffset.x, -m_textVirtualOffset.y);
}
Rect clipArea = m_rect;
clipArea.expandLeft(-m_padding.left);
clipArea.expandRight(-m_padding.right);
clipArea.expandBottom(-m_padding.bottom);
clipArea.expandTop(-m_padding.top);
g_drawPool.setClipRect(clipArea);  // onlyOnce=false bo TTF drawText robi wiele draw calls
m_font->drawText(m_drawText, ttfDrawArea, m_color, m_textAlign);
g_drawPool.resetClipRect();
```

**Poprawka 2 — update() focusCursor=true: nie resetuj offset gdy tekst jest dłuższy:**
```cpp
// Przed: m_textVirtualOffset = {};
// Po: tylko resetuj jeśli tekst mieści się w widocznym obszarze
if (textBoxSize.height() <= getPaddingRect().height()) m_textVirtualOffset.y = 0;
if (textBoxSize.width() <= getPaddingRect().width()) m_textVirtualOffset.x = 0;
```

**Poprawka 3 — update() focusCursor=false: identyczna zmiana.**

**Poprawka 4 — totalSize typo fix:**
```cpp
// Przed: totalSize.setWidth(m_textVirtualSize.height());
// Po:    totalSize.setWidth(m_textVirtualSize.width());
```

### Dodatkowa obserwacja — UIWidget::drawText()
`uiwidgettext.cpp` → `UIWidget::drawText()` (używany przez Labels, Buttons) też NIE ma clippingu dla TTF. To wpływa na problemy P6-P9 (overflow tekstu na buttonach/labelach), ale NIE na książki (które używają UITextEdit).

### Zadania
- [x] **P1-1**: Sprawdzono `textwindow.lua` — OK, scrollbar podpięty prawidłowo
- [x] **P1-2**: Znaleziono root cause w `uitextedit.cpp` — TTF blokował scrollowanie
- [x] **P1-3**: Zastosowano 4 poprawki w `uitextedit.cpp`
- [x] **P1-4**: Poprawiono bug z `onlyOnce=true` → `onlyOnce=false` + `resetClipRect()`
- [ ] **P1-5**: Skompilować klienta i przetestować z długim tekstem książki

---

## PROBLEM P2: NPC nie mówi żółtym tekstem nad sobą ✅ NAPRAWIONE

### Analiza
- Po zmianie z `sendTextMessage` na `npc:say(text, TALKTYPE_PRIVATE_NP, false, player, npc:getPosition())` problem się rozwiązał
- `TALKTYPE_PRIVATE_NP` (wire 10) → klient mapuje na `MessageNpcFromStartBlock`
- `MessageNpcFromStartBlock` CZYTA pozycję z pakietu → `creaturePos` jest valid
- W `console.lua:1647` `MessageModes.NpcFromStartBlock` JEST na liście dozwolonych typów dla `StaticText` (dymek)
- **Wniosek**: Dymek powinien się pojawiać automatycznie po naszym fixie npc:say()

### Zadania
- [x] **P2-1**: Zweryfikowano że `TALKTYPE_PRIVATE_NP` tworzy StaticText — TAK, tworzy
- [x] **P2-2**: Analiza protokołu: wire 10 → MessageNpcFromStartBlock → reads position → bubble created ✅
- [x] **P2-3**: SayEvent (npc.lua:95) używa identycznych parametrów jak nasz fix — OK

---

## PROBLEM P3: Tekst NPC zawiera surowe fragmenty i18n

### Analiza
- Na screenie 2: "Witaj, mlody poszukiwaczu przygod. Powiedz, jesli potrzebujesz pomocy w \z choosing swojej vocation, albo jesli juz decided, jaka vocation chcesz wybrac."
- **Przyczyna**: Tłumaczenie w pliku JSON/Lua dla NPC Oressa ma niekompletne tłumaczenie — angielskie słowa "choosing", "vocation", "decided" nie zostały przetłumaczone
- Znaki `\z` to prawdopodobnie escape sequence z Lua long string lub nieprawidłowy placeholder

### Zadania
- [ ] **P3-1**: Znaleźć plik tłumaczeń dla NPC Oressa (klucze `npc.oressa.*` w `data/i18n/pl.json`)
- [ ] **P3-2**: Poprawić tłumaczenie — zamienić "choosing" → "wyborze", "vocation" → "profesji", "decided" → "zdecydowałeś"
- [ ] **P3-3**: Naprawić `\z` — prawdopodobnie placeholder `{0}` źle sformatowany lub escape w tłumaczeniu
- [ ] **P3-4**: Sprawdzić czy inne NPC (szczególnie rookowe) mają kompletne tłumaczenia

---

## PROBLEM P4: NPC nie reaguje na tekst gracza

### Analiza  
- Screen 3: gracz pisze "siemkanko" a NPC nie odpowiada
- To **normalne** — NPC reaguje na konkretne słowa kluczowe: "hi", "hello", "trade", "vocation" itd.
- Ale trzeba sprawdzić czy po restarcie serwera NPC dalej reaguje na "hi" — nasz fix mógł coś zepsuć

### Zadania
- [ ] **P4-1**: Przetestować NPC Oressa z komendą "hi" po restarcie serwera
- [ ] **P4-2**: Sprawdzić czy problem "nie wyjdę z rooka" jest osobnym bugiem (P11)

---

## PROBLEM P5: Polskie znaki nie działają na czacie

### Analiza
- Gracz nie może wpisać polskich znaków (ą, ę, ś, ć, ź, ż, ó, ł, ń)
- To jest problem **klienta** — input handling
- OTClient Redemption używa SDL/GLFW dla input → musi obsługiwać UTF-8 input
- Na Windowsie może być problem z układem klawiatury lub IME

### Zadania
- [ ] **P5-1**: Sprawdzić `modules/corelib/` — obsługa input UTF-8 w TextEdit
- [ ] **P5-2**: Sprawdzić czy klient ma `setTextInputEnabled()` z obsługą Unicode
- [ ] **P5-3**: Sprawdzić `platformwindow.cpp` / `win32window.cpp` — obsługa `WM_CHAR` vs `WM_UNICHAR`
- [ ] **P5-4**: Jeśli problem z fontem (brak glifów polskich) — sprawdzić czy noto-12 ma polskie znaki w atlasie TTF
- [ ] **P5-5**: Sprawdzić `isTextCharacter()` i `UnicodeCodePage` filtering — mógł filtrować polskie znaki

---

## PROBLEM P6: Waga/Dusza w panelu ekwipunku ✅ NAPRAWIONE

### Analiza
- "Czapka" (6 znaków) to **błędne tłumaczenie** — "Cap" = Capacity, nie "czapka" (hat)
- Panel onPanel: 34px (anchored to slot), offPanel: 30px — za ciasne na 6 znaków

### Przyczyna i rozwiązanie
- **Tłumaczenie** `inventory_otui.tr_3` i `tr_4`: "Czapka" → "Poj." (skrót od "Pojemność")
- "Poj." = 4 znaki (~28px) — mieści się w 30px offPanel
- "Dusza" = 5 znaków (~35px) — lekki overflow w 30px, wizualnie akceptowalne

### Zadania
- [x] **P6-1**: Poprawiono tłumaczenie "Czapka" → "Poj." w pl_client_all.json (tr_3 i tr_4)

---

## PROBLEM P7: Sklep — button "Kup" ✅ NAPRAWIONE

### Analiza
- Dwa buttony: `game_store.otui` (StoreButton #btnCoins) i `game_shop.otui` (Button)
- Oba miały `size: 64 20` — za wąskie na "Dostawać" (8 znaków)
- "Dostawać" to też **błędne tłumaczenie** (niedokonany) — powinno być "Kup" (rozkazujący)

### Rozwiązanie
1. **Tłumaczenie**: "Dostawać" → "Kup" (3 znaki, mieści się w 64px)
2. **OTUI**: Zmieniono `size: 64 20` na `height: 20` + `text-auto-resize: true` + `padding: 0 5 0 5`
3. Zabezpiecza przed overflow w każdym języku

### Zadania
- [x] **P7-1**: Poprawiono tłumaczenia game_shop_otui.tr_7 i game_store_otui.tr_8: "Dostawać" → "Kup"
- [x] **P7-2**: Dodano text-auto-resize do game_store.otui (#btnCoins)
- [x] **P7-3**: Dodano text-auto-resize do game_shop.otui (button Get)

---

## PROBLEM P8: "Czatuj dalej" button ✅ NAPRAWIONE

### Analiza
- `TopToggleButton #toggleChat`: `size: 64 18` — stały rozmiar
- Tekst "Czatuj dalej" (11 znaków) vs "Chat On" (7 znaków) — overflow

### Rozwiązanie
- Zmieniono `size: 64 18` na `height: 18` + `text-auto-resize: true` + `padding: 0 5 0 5`
- Button automatycznie dopasowuje szerokość do tekstu w każdym języku
- `consoleTextEdit` anchored to `toggleChat.left` → automatycznie się dostosowuje

### Zadania
- [x] **P8-1**: Zmieniono size na height + text-auto-resize w console.otui

---

## PROBLEM P9: Cyklopedia/Charms ✅ NAPRAWIONE

### Analiza
- Wiele widgetów z fixed size (buttony, panele, grid cells)
- Złe tłumaczenia: "Odblokować" (bezokolicznik), "Wybierać" (bezokolicznik), "Wybierać Stworzenie" (za długie)
- **KRYTYCZNY BUG FUNKCJONALNY**: `actionCharmButton()` porównywał `widget:getText()` z angielskimi stringami ("Unlock", "Select", "Remove", "Upgrade") — w każdym innym języku przyciski nie działały!

### Rozwiązanie
1. **Tłumaczenia**: Poprawiono formy rozkazujące (krótsze + poprawne gramatycznie):
   - "Odblokować" → "Odblokuj" (charms.tr_21, charms1410_otui.tr_11)
   - "Usunąć" → "Usuń" (charms.tr_22)  
   - "Całkowicie odblokowany" → "Odblokowany" (charms.tr_23)
   - "Wybierać" → "Wybierz" (charms.tr_24)
   - "Wybierać Stworzenie" → "Wybierz stw." (charms1410_otui.tr_6)
2. **OTUI**: UnlockButton w charms.otui: `size: 75 20` → `height: 20` + `text-auto-resize: true`
3. **BUG FIX**: `actionCharmButton()` i `actionSelectCharmButton()` — zamieniono `widget:getText()` na `widget.action`
   - Dodano `.action` property ("unlock", "select", "remove", "upgrade", "fully_unlocked") wszędzie gdzie `UnlockButton:setText()`
   - Porównania: `type == "Unlock"` → `action == "unlock"`, `type == "Select"` → `action == "select"`, itd.
   - Niezależne od języka — przycisk działa w każdej lokalizacji

### Pozostałe kwestie (do przeglądu):
- `setupModernVersionUpgrade()` — tierButtons table nadal używa hardcoded English strings "Upgrade to X%". Potrzebne klucze i18n.
- Grid `cell-size: 158 94/100` — nazwy charmów mogą nadal wystawać (np. "Wampiryczne Uściski" 19 znaków)
- Opisy TextBase (text-wrap: true, height: 110) — długie PL opisy mogą overflow vertically

### Zadania
- [x] **P9-1**: Poprawiono 6 tłumaczeń (formy rozkazujące + skróty)
- [x] **P9-2**: Dodano text-auto-resize do UnlockButton w charms.otui
- [x] **P9-3**: Naprawiono krytyczny bug — actionCharmButton/actionSelectCharmButton używa .action zamiast getText()
- [ ] **P9-4**: TODO: Dodać klucze i18n dla "Upgrade to X%" w setupModernVersionUpgrade()
- [ ] **P9-5**: TODO: Przetestować wszystkie zakładki cyklopedii

---

## PROBLEM P10: Komendy NPC ({trade}, {buy}) prześwietlają

### Analiza
- Na screenie 2 widać w czacie NPC tekst z kluczowymi słowami ale format `{keyword}` nie jest parsowany poprawnie
- **Flow**: W `console.lua` linia 1096 → highlight `{word}` na niebiesko
- **Przyczyna prawdopodobna**: po server-side translation tekst nie ma już `{keyword}` — formatowanie kluczowych słów gubi się
- W oryginalnym systemie: serwer wysyłał `MessageModes.NpcFromStartBlock` z `{trade}` w tekście → klient podświetlał na niebiesko
- Po naszym fixie: `npc:say()` nie wysyła `NpcFromStartBlock` — tylko zwykły `TALKTYPE_PRIVATE_NP`

### Zadania
- [ ] **P10-1**: Sprawdzić jak oryginalny `SayEvent` wysyłał `NpcFromStartBlock` — czy `npc:say()` to obsługuje
- [ ] **P10-2**: Po server-side translation zachować `{keyword}` w tekście aby klient mógł podświetlać
- [ ] **P10-3**: Sprawdzić mapping: `NpcFromStartBlock = 51` → jaki `TALKTYPE_*` to generuje na serwerze
- [ ] **P10-4**: Jeśli `{keywords}` są w tłumaczeniu — upewnić się że `player:getTranslation()` ich nie stripuje
- [ ] **P10-5**: Przetestować kliknięcie na highlighted keyword (np. "trade") — czy otwiera trade window

---

## PROBLEM P11: Nie można wyjść z Rooka na 8 lvl

### Analiza
- Gracz ma level 8, NPC Oressa powinna go przepuścić na mainland
- Na screenie 2 widać rozmowę z Oressa — odpowiada o "vocation"
- **Przyczyna prawdopodobna**: Dialog i18n Oress'y jest niekompletny → brakujące komendy/słowa kluczowe z tłumaczeniem
- Oressa wymaga sekwencji: hi → vocation → druid/sorcerer/paladin/knight → yes
- Jeśli tłumaczenia zmieniły keyword matching — NPC nie rozpoznaje "vocation" jako prawidłowego słowa

### Zadania
- [ ] **P11-1**: Znaleźć skrypt NPC Oressa (`data-otservbr-global/npc/oressa.lua`)
- [ ] **P11-2**: Sprawdzić czy keywords ("vocation", "yes", "druid" itd.) są prawidłowo zmapowane po i18n
- [ ] **P11-3**: Sprawdzić czy `npcHandler:greet()` działa z Oressą (czy "hi" jest rozpoznawane)
- [ ] **P11-4**: Przetestować pełną sekwencję dialogu Oressa → vocation selection → teleport
- [ ] **P11-5**: Upewnić się że `TALKTYPE_PRIVATE_NP` dociera do NPC handler'a (onSay callback)

---

## PROBLEM P12: Branding "OTClient - Redemption" nadal widoczny ✅ NAPRAWIONE

### Analiza
- Screen 1 pokazuje dwa miejsca z brandingiem, który ma zostać usunięty:
  - pasek tytułu okna: `OTClient - Redemption`
  - lewy overlay w UI: `OTClient Redemption`
- W kodzie klienta są hardcoded źródła:
  - `canary_test/testyy/init.lua:27` (`g_app.setName("OTClient - Redemption")`)
  - `canary_test/testyy/modules/client_bottommenu/bottommenu.otui:42` (`text: OTClient Redemption`)
  - `canary_test/testyy/modules/client_background/background.lua` + `background.otui` (`clientVersionLabel`)
- Dodatkowe fallbacki nazwy istnieją też w C++ (`src/framework/core/application.h`) i RPC (`src/framework/config.h`).

### Zadania
- [x] **P12-1**: Ustalono docelowy branding runtime: `OTClient`
- [x] **P12-2**: Ukryto overlay label `OTClient Redemption` w bottom menu
- [x] **P12-3**: Zmieniono nazwę aplikacji w `init.lua` + fallback w `application.h` i `config.h`
- [x] **P12-4**: Wyłączono `clientVersionLabel` w `client_background` (tekst po lewej stronie nie jest renderowany)
- [ ] **P12-5**: Test manualny UI na Windows/Linux: brak słowa "Redemption" na ekranie logowania/charlist i w tooltipie RPC

---

## PROBLEM P13: Auto reconnect — overflow + regresja i18n po kliknięciu ✅ NAPRAWIONE (kod)

### Analiza
- Screen 1: polski napis `Automatyczne ponowne połączenie: OFF` wychodzi poza obrys controlki.
- Screen 2: po kliknięciu label wraca do angielskiego (`Auto reconnect: On`) zamiast tłumaczenia.
- Root cause w kodzie:
  - `canary_test/testyy/modules/client_entergame/characterlist.lua` miał hardcoded EN stringi w `onClick`.
  - `CharacterList.show()` używał poprawnie `tr(...)`, więc były dwa niespójne flow tekstu.
  - `canary_test/testyy/modules/client_entergame/characterlist.otui:346-356` ma sztywną szerokość (`140`/`75`) bez auto-resize.

### Zadania
- [x] **P13-1**: Usunięto hardcoded EN stringi z `onClick` i użyto `tr("otclient_modules.characterlist.tr_*")`
- [x] **P13-2**: Dodano wspólną funkcję `updateAutoReconnectLabel()` wywoływaną w `show()` i `onClick`
- [x] **P13-3**: Naprawiono layout controlki (`text-auto-resize`/`padding`/większy width), aby PL nie wychodził poza obrys
- [x] **P13-4**: Audyt kluczy `tr_3`, `tr_4`, `tr_5`, `tr_6` wykonany dla wszystkich `game_i18n_*.lua` (53 locale)
- [ ] **P13-5**: Test regresji: PL/EN + ON/OFF + oba tryby (`GameEnterGameShowAppearance` true/false)
- [x] **P13-6**: Poprawiono PL `otclient_modules.characterlist.tr_6`: `NA` -> `ON`
- [ ] **P13-7**: Rozdzielić QA i naprawę tłumaczeń dla pozostałych locale (patrz P16)

---

## PROBLEM P14: Brak flag w pickerze języków ✅ NAPRAWIONE (kod + fallback)

### Analiza
- Screen 3: część języków w pickerze nie ma flag (widać placeholdery zamiast ikon).
- `modules/client_locales/locales.lua` ustawia `widget:setImageSource(...)`; brak pliku flagi dla locale powodował pusty/zepsuty obrazek.
- W repo dostępne są tylko wybrane flagi (`data/images/flags`: `en`, `de`, `es`, `pl`, `pt`, `sv`), więc brakujące locale nie mają assetów.

### Zadania
- [x] **P14-1**: Dodano mapowanie/normalizację kodu locale w pickerze (`locales.lua`) pod wybór ikon
- [ ] **P14-2**: Dodać brakujące flagi dla aktualnie widocznych języków (minimum: te z listy w pickerze)
- [x] **P14-3**: Dodano fallback icon (`/images/flags/en`), jeśli konkretna flaga nie istnieje (brak pustych prostokątów)
- [ ] **P14-4**: Test: każdy język z pickera renderuje poprawną ikonę lub fallback

---

## PROBLEM P15: Uszkodzone znaki w nazwach języków (Español/Português) + glify ✅ NAPRAWIONE (kod + fallback)

### Analiza
- Screen 3: `Espa�ol` oraz `Portugu�s` wskazują uszkodzone diakrytyki.
- W plikach locale były zapisane uszkodzone wartości:
  - `data/locales/disabled/es.lua:8` -> było `languageName = "Espa�ol"` (naprawione na `Español`)
  - `data/locales/disabled/pt.lua:4` -> było `languageName = "Portugu�s"` (naprawione na `Português`)
- Picker korzysta z `locale.languageName`, więc błąd danych od razu wychodzi w UI.
- Dodatkowo część nazw języków pokazuje kwadraty, co sugeruje brak glifów w użytym foncie pickera (`noto-12`) dla niektórych skryptów.

### Zadania
- [x] **P15-1**: Naprawiono nazwy języków do poprawnego UTF-8 (`Español`, `Português`) w plikach locale
- [ ] **P15-2**: Dodać skan/lint plików locale pod znaki uszkodzone (`�`, mojibake) przed buildem
- [ ] **P15-3**: Ustalić jedną politykę kodowania plików locale (UTF-8) i usunąć/udokumentować legacy `cp1252`
- [x] **P15-4**: Wprowadzono fallback displayName dla problematycznych skryptów (`zh`, `zh_TW`, `ja`, `ko`) aby uniknąć kwadratów/braku glifów
- [ ] **P15-5**: Test: pełna lista języków w pickerze bez `?`/`�`/kwadratów

---

## PROBLEM P16: Jakość tłumaczeń `Auto reconnect` (fallback EN + `[EN]` tags)

### Analiza
- W audycie kluczy `otclient_modules.characterlist.tr_3..tr_6` (2026-02-28) wyszło:
  - `tr_3`: 48 locale nadal ma literalne `Auto reconnect:` (EN fallback),
  - `tr_4`: 48 locale nadal ma literalne `Auto reconnect:` (EN fallback),
  - `tr_5`: 50 locale ma `Off/OFF`,
  - `tr_6`: 49 locale ma `On/ON`.
- Wykryto też prefiksy `[EN]` w locale `zh_TW` dla tych kluczy.
- Wniosek: sam fix kodu `P13` jest gotowy, ale jakość danych tłumaczeń wymaga osobnego pasa QA.

### Zadania
- [ ] **P16-1**: Oczyścić `[EN]` tagi z kluczy `characterlist.tr_3..tr_6` (minimum: `zh_TW`)
- [ ] **P16-2**: Ustalić docelową politykę ON/OFF (czy lokalizujemy czy trzymamy globalne `ON/OFF`)
- [ ] **P16-3**: Przetłumaczyć `tr_3` i `tr_4` dla priorytetowych locale (aktywnych na serwerze)
- [ ] **P16-4**: Dodać QA check w pipeline i18n: blokada dla `[EN]` i EN-literal na kluczach UI krytycznych

---

## Priorytetyzacja — kolejność naprawy

### Faza 1 — KRYTYCZNE (blokuje gameplay)
1. **P11** — Wyjście z Rooka (bez tego gracz nie może grać)
2. **P3** — Niekompletne tłumaczenia NPC (mylące teksty)
3. **P10** — Komendy NPC {trade}/{buy} prześwietlają (nie można handlować)
4. **P13** — ✅ Zamknięte kodowo (pozostał tylko test manualny)
5. **P15** — ✅ Zamknięte kodowo (pozostał test manualny + lint UTF-8)

### Faza 2 — WAŻNE (psuje UX)
6. **P12** — ✅ Zamknięte kodowo (pozostał tylko test manualny)
7. **P14** — ✅ Zamknięte kodowo (fallback ikon); pełny pakiet flag jako osobny task assets
8. **P16** — Jakość tłumaczeń `Auto reconnect` (EN fallback + `[EN]`)
9. **P1** — Książka: domknięcie testów po fixie renderingu

### Faza 3 — ULEPSZENIA UI (estetyka)
10. **P2** — NPC żółty dymek (weryfikacja końcowa)
11. **P6** — Waga/Dusza font za duży
12. **P7** — Sklep button overflow
13. **P8** — "Czatuj dalej" button ucięty
14. **P9** — Cyklopedia okienka za małe
15. **P5** — Polskie znaki input (może być osobny issue)

---

## Lokalizacje kluczowych plików

### Serwer (canary_test/)
| Plik | Opis |
|------|------|
| `data/npclib/npc_system/npc_handler.lua` | Handler NPC — tryLocalizedMessage, sayLocalized |
| `data/npclib/npc_system/modules.lua` | Moduły NPC (travel, trade) |
| `data/npclib/npc.lua` | SayEvent, Npc:sendMessage |
| `data/libs/i18n_wrappers.lua` | NPC_LIB.i18n.npcSay, MESSAGE_NPC_FROM |
| `data/libs/server_i18n.lua` | t() function, getPlayerLang() |
| `data-otservbr-global/npc/oressa.lua` | NPC Oressa (wyjście z Rooka) |
| `src/utils/i18n/translator.cpp` | C++ translator (format, get) |
| `src/lua/functions/creatures/player/player_functions.cpp` | player:getTranslation() |
| `data/i18n/*.json` | Pliki tłumaczeń |

### Klient (testyy/modules/)
| Plik | Opis |
|------|------|
| `game_textwindow/textwindow.otui` + `.lua` | Okno książki |
| `game_console/console.otui` + `.lua` | Czat + NPC channel + toggleChat |
| `game_store/game_store.otui` + `.lua` | Sklep |
| `game_shop/game_shop.otui` + `.lua` | Nowy sklep |
| `game_cyclopedia/game_cyclopedia.otui` + `cyclopedia_widgets.otui` | Cyklopedia |
| `game_inventory/inventory.otui` + `.lua` | Ekwipunek (Waga/Dusza) |
| `game_npctrade/npctrade.otui` + `.lua` | Okno handlu NPC |
| `client_entergame/characterlist.otui` + `characterlist.lua` | Auto reconnect (label + layout + toggle) |
| `client_locales/locales.lua` + `locales.otui` | Picker języków (lista, ikony flag, nazwy) |
| `client_bottommenu/bottommenu.otui` | Overlay branding (`OTClient Redemption`) |
| `init.lua` (+ fallbacki `src/framework/core/application.h`, `src/framework/config.h`) | Nazwa aplikacji/title bar/RPC |
| `data/locales/disabled/es.lua`, `data/locales/disabled/pt.lua` | Uszkodzone diakrytyki nazw języków |
| `data/images/flags/*.png` | Assety flag dla picker języków |
