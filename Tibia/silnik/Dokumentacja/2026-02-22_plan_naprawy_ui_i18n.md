# Plan naprawy problemów UI klienta + serwera — i18n
**Data**: 2026-02-22  
**Status**: PLAN — analiza + zadania  
**Źródło**: Screeny z testów 22.02.2026, OTClient Redemption  
**Aktualizacja**: 2026-02-28 — nowe problemy UI/i18n + synchronizacja statusów z wdrożonym kodem (screeny 1-7: branding, auto-reconnect, picker języków, retest czatu/książek/inwentarza) + domknięcie hardcoded w cyklopedii/bestiary, synchronizacja runtime locale (`game_i18n_en/pl`) i cleanup artefaktów debug w zakładce House  

---

## Spis problemów (ze screenów)

| # | Screen | Problem | Priorytet | Typ |
|---|--------|---------|-----------|-----|
| P1 | 1 | ✅ Tekst w oknie książki wychodzi poza okno | WYSOKI | Klient UI |
| P2 | 2 | ✅ NPC nie mówi żółtym tekstem nad sobą (naprawione zmianą na npc:say + TALKTYPE_PRIVATE_NP) | WYSOKI | Serwer + Klient |
| P3 | 2 | ⚠️ Oressa: poprawiono klucze PL i usunięto `\z`; czeka retest + audyt innych NPC | WYSOKI | Serwer i18n |
| P4 | 3 | NPC nie reaguje na "siemkanko" (brak odpowiedzi) | ŚREDNI | Serwer NPC |
| P5 | 2,3 | ✅ Litery specjalne da się wpisywać (`łżć...`), ale rendering inputu jest błędny (patrz P21) | ŚREDNI | Klient input |
| P6 | 5 | ⚠️ Poprawka layoutu + zmniejszenie fontów (`Waga`/`Dusza`) wdrożone w `inventory.otui`, czeka retest runtime | ŚREDNI | Klient UI |
| P7 | 4 | ✅ Sklep: button "Kup" + text-auto-resize | ŚREDNI | Klient UI |
| P8 | 5 | ⚠️ Poprawka szerokości `toggleChat` wdrożona (`width: 176` + większy padding), czeka retest runtime | WYSOKI | Klient UI |
| P9 | 5 | ⚠️ Cyklopedia/Bestiary/Boss Slots: usunięto hardcoded EN + dodano brakujące klucze i18n, czeka pełny retest zakładek | ŚREDNI | Klient UI |
| P10 | 2 | ⚠️ Mapping zweryfikowany w kodzie; czeka retest klikanych keywordów `{trade}`/`{buy}` | WYSOKI | Serwer + Klient |
| P11 | - | ⚠️ Do potwierdzenia runtime: brak blokera w analizie kodu, wymaga pełnego testu dialogu | WYSOKI | Serwer NPC |
| P12 | 1 | ✅ Branding "OTClient - Redemption" i "OTClient Redemption" usunięty z runtime UI | ŚREDNI | Klient UI/Branding |
| P13 | 1,2 | ✅ Auto reconnect: usunięty hardcoded EN + poprawiony layout controlki (większa szerokość i multiline) | WYSOKI | Klient UI + i18n |
| P14 | 3,5 | ⚠️ Poprawka picker UI + fallback ikon wdrożone, czeka retest buildu i asset pipeline | WYSOKI | Klient assets/UI |
| P15 | 3 | ✅ Uszkodzone znaki nazw języków naprawione (es/pt) + fallback nazw dla problematycznych skryptów | WYSOKI | Klient i18n/font |
| P16 | 3 | Jakość tłumaczeń `Auto reconnect`: 48/53 locale z EN fallback + wykryte `[EN]` tagi (np. `zh_TW`) | ŚREDNI | Klient i18n/QA |
| P20 | - | ⚠️ Bozo: naprawiono błędy składni Lua i fallback `i18nKey -> text`; czeka retest startu serwera | WYSOKI | Serwer NPC |
| P21 | 5,7 | ⚠️ Baseline/padding inputu poprawione w kodzie, czeka retest runtime | WYSOKI | Klient text render/UI |
| P22 | 6 | ⚠️ Selekcja/copy książki poprawione w kodzie, czeka retest runtime | WYSOKI | Klient UI/UX |
| P23 | 6 | ⚠️ Reguła „komenda stała, nazwa lokalna” wdrożona w `spellbook.lua`, czeka retest | WYSOKI | Klient i18n/content |
| P24 | 7 | ⚠️ Dodano wymuszony wrap długich tokenów w czacie, czeka retest we wszystkich kanałach | WYSOKI | Klient UI/chat |
| P25 | - | ⚠️ Cyklopedia/House: usunięto artefakty debug (`asdasd`, `22222`...) + część hardcoded etykiet, czeka retest | ŚREDNI | Klient UI/i18n |
| P26 | 5 | ⚠️ Opcje: zsynchronizowano brakujące klucze runtime (`data_options/options`) i poprawiono mapping delay, czeka retest | WYSOKI | Klient UI/i18n |

---

## Dowody wizualne (zgłoszenie 2026-02-28)
- **Screen 1 (przed)**: widoczny branding `OTClient - Redemption` + overflow napisu `Automatyczne ponowne połączenie: OFF`.
- **Screen 2 (przed)**: po kliknięciu auto reconnect label przechodził na hardcoded EN (`Auto reconnect: On`).
- **Screen 3 (przed)**: picker języków bez części flag + błędne nazwy (`Espa�ol`, `Portugu�s`) i kwadraty glifów.
- **Screen 5 (retest)**: litery diakrytyczne można wpisać, ale opadają/ucinają się w polu wpisywania; `Czatuj dalej` nadal za wąskie; `Waga/Dusza` nadal nie mieszczą się.
- **Screen 6 (retest)**: w książce treści czarów nie trzymają reguły lokalizacji (komenda vs nazwa czaru).
- **Screen 7 (retest)**: wiadomości na czacie lokalnym wychodzą poza obramówkę listy wiadomości.
- **Status po retescie**: P1 i sam input Unicode są częściowo potwierdzone, ale P6/P8/P14 wróciły jako otwarte; dodano P21-P24.

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
- [x] **P3-1**: Zlokalizowano klucze Oressy w `canary_test/i18n/pl/npc.json`
- [x] **P3-2**: Poprawiono `npc.oressa.greet_msg_1` (naprawa formy PL przy zachowaniu keywordów `{choosing}` / `{vocation}` / `{decided}`)
- [x] **P3-3**: Usunięto artefakty `\z` z `npc.oressa.greet_msg_1` i `npc.oressa.greet_msg_2`; poprawiono też `npc.oressa.farewell_msg_1`
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

## PROBLEM P5: Polskie znaki na czacie (INPUT) — STATUS: CZĘŚCIOWO NAPRAWIONE

### Analiza
- Retest potwierdził, że znaki specjalne (`ł`, `ż`, `ć`, itd.) da się wpisywać.
- Pierwotny blocker inputu Unicode jest usunięty.
- Pozostaje problem renderingu wpisywanej linii (P21).

### Zadania
- [x] **P5-1**: Potwierdzono w teście runtime wpisywanie znaków diakrytycznych
- [x] **P5-2**: Zamknięto pierwotny problem "brak możliwości wpisywania liter specjalnych"
- [ ] **P5-3**: Dokończyć przez naprawę renderingu linii input (P21)

---

## PROBLEM P6: Waga/Dusza w panelu ekwipunku ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

### Analiza
- "Czapka" (6 znaków) to **błędne tłumaczenie** — "Cap" = Capacity, nie "czapka" (hat)
- Panel onPanel: 34px (anchored to slot), offPanel: 30px — za ciasne na 6 znaków

### Retest (screen 5)
- W obecnym buildzie testowym `Dusza` i `Waga` nadal nie mieszczą się prawidłowo.
- Poprzedni fix tłumaczenia nie domknął problemu layoutu.

### Zadania
- [x] **P6-1**: Poprawiono tłumaczenie "Czapka" → "Poj." w pl_client_all.json (tr_3 i tr_4)
- [x] **P6-2**: Zweryfikowano aktywny layout pliku i wdrożono poprawki w `modules/game_inventory/inventory.otui`
- [x] **P6-3**: Dostosowano szerokości/padding/anchory etykiet (`Waga`, `Dusza`) + `text-auto-resize`
- [x] **P6-3b**: Zmniejszono fonty i wartości (`small-9px` + `verdana-11`) w panelach `Waga`/`Dusza`
- [ ] **P6-4**: Test manualny: brak overflow w panelu ekwipunku

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

## PROBLEM P8: "Czatuj dalej" button ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

### Analiza
- `TopToggleButton #toggleChat`: `size: 64 18` — stały rozmiar
- Tekst "Czatuj dalej" (11 znaków) vs "Chat On" (7 znaków) — overflow

### Retest (screen 5)
- Przycisk nadal nie rozszerza się poprawnie i ucina tekst.
- Potrzebna weryfikacja aktywnego stylu/przycisku, bo runtime zachowuje się inaczej niż zakładany fix.

### Zadania
- [x] **P8-1**: Zmieniono size na height + text-auto-resize w console.otui
- [x] **P8-2**: Sprawdzono style aktywne (`modules/game_console/console.otui` oraz `data/styles/40-console.otui`)
- [x] **P8-3**: Dodano wymuszenie szerokości przycisku (`toggleChat width: 176`) + auto-resize/padding
- [ ] **P8-4**: Test PL/EN i długie stringi bez ucinania

---

## PROBLEM P9: Cyklopedia/Charms/Boss Slots ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

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

### Dodatkowe poprawki (2026-02-28, po retescie):
- `setupModernVersionUpgrade()` nie używa już hardcoded EN — podpięto klucz `otclient_modules.charms.tr_75` (`Upgrade to %d%%`).
- Usunięto hardcoded stringi EN z `boss_slots.lua` i `bosstiary.lua` (sloty, tooltipy, info label, remove tooltip) na rzecz `tr("otclient_modules.boss_slots.*")`.
- Usunięto hardcoded tooltip `"Sensitive to ..."` i `(fully unlocked)` w `bestiary.lua` na rzecz kluczy `otclient_modules.bestiary.tr_14/tr_15`.
- Dostosowano szerokości/przyciski z tekstem w cyklopedii i bestiary (`game_cyclopedia.otui`, `bestiary.otui`, `cyclopedia_widgets.otui`) przez `text-auto-resize` + większe szerokości/padding.
- Usunięto hardcoded `tr("Voc.")` w zakładce Items przez nowy klucz `otclient_modules.items_otui.vocation_short`.

### Zadania
- [x] **P9-1**: Poprawiono 6 tłumaczeń (formy rozkazujące + skróty)
- [x] **P9-2**: Dodano text-auto-resize do UnlockButton w charms.otui
- [x] **P9-3**: Naprawiono krytyczny bug — actionCharmButton/actionSelectCharmButton używa .action zamiast getText()
- [x] **P9-4**: Dodano klucze i18n dla "Upgrade to X%" (`otclient_modules.charms.tr_75`) + podpięto w `setupModernVersionUpgrade()`
- [x] **P9-5**: Dodano brakujące klucze EN/PL do `otclient_modules.json` dla opcji (`options.category_*`) i nowych stringów cyklopedii/bestiary
- [ ] **P9-6**: Test manualny: pełny retest zakładek cyklopedii/bestiary/boss slots po nowej kompilacji

---

## PROBLEM P10: Komendy NPC ({trade}, {buy}) prześwietlają

### Analiza
- Na screenie 2 widać w czacie NPC tekst z kluczowymi słowami ale format `{keyword}` nie jest parsowany poprawnie
- **Flow**: W `console.lua` linia 1096 → highlight `{word}` na niebiesko
- Po analizie kodu (`npc.lua` / `npc_handler.lua` / `protocolgame.cpp`) `npc:say(..., TALKTYPE_PRIVATE_NP, ...)` przechodzi normalną ścieżką `sendCreatureSay` i nadal jest mapowany po stronie klienta do trybu NPC (`NpcFrom` / `NpcFromStartBlock`).
- Wniosek: ryzyko dotyczy raczej jakości samych tłumaczeń (utrata nawiasów `{}` lub zły tekst), a nie typu wiadomości.

### Zadania
- [x] **P10-1**: Zweryfikowano `SayEvent` i `npc:say()` — ścieżka jest prawidłowa dla `TALKTYPE_PRIVATE_NP`
- [ ] **P10-2**: Po server-side translation zachować `{keyword}` w tekście aby klient mógł podświetlać
- [x] **P10-3**: Zweryfikowano mapping po stronie klienta (`NpcFrom` i `NpcFromStartBlock` obsługiwane jako `npcChat`)
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
  - `canary_test/testyy/modules/client_entergame/characterlist.otui` miał zbyt małą szerokość (`140`/`75`) bez prawidłowego multiline.

### Zadania
- [x] **P13-1**: Usunięto hardcoded EN stringi z `onClick` i użyto `tr("otclient_modules.characterlist.tr_*")`
- [x] **P13-2**: Dodano wspólną funkcję `updateAutoReconnectLabel()` wywoływaną w `show()` i `onClick`
- [x] **P13-3**: Naprawiono layout controlki (`text-auto-resize`/`padding`/większy width + multiline): `290x24` (appearance) oraz `195x30` (classic)
- [x] **P13-4**: Audyt kluczy `tr_3`, `tr_4`, `tr_5`, `tr_6` wykonany dla wszystkich `game_i18n_*.lua` (53 locale)
- [ ] **P13-5**: Test regresji: PL/EN + ON/OFF + oba tryby (`GameEnterGameShowAppearance` true/false)
- [x] **P13-6**: Poprawiono PL `otclient_modules.characterlist.tr_6`: `NA` -> `ON`
- [ ] **P13-7**: Rozdzielić QA i naprawę tłumaczeń dla pozostałych locale (patrz P16)

---

## PROBLEM P14: Brak flag w pickerze języków ⚠️ POPRAWKA W KODZIE / CZEKA RETEST BUILD

### Analiza
- Screen 3 pokazywał brak flag; po dodaniu plików i fallbacku retest (screen 5) nadal nie pokazuje flag w runtime.
- To sugeruje problem pipeline assetów/ładowania/cachowania, a nie wyłącznie brak plików.

### Zadania
- [x] **P14-1**: Dodano mapowanie/normalizację kodu locale w pickerze (`locales.lua`) pod wybór ikon
- [x] **P14-2**: Dodano pakiet flag (w tym placeholdery dla brakujących locale)
- [x] **P14-3**: Dodano fallback icon (`/images/flags/en`), jeśli konkretna flaga nie istnieje (brak pustych prostokątów)
- [x] **P14-3b**: Poprawiono layout `LocalesButton` w `locales.otui` (`image-size`, `image-auto-resize`, `text-offset`, `cell-size`)
- [x] **P14-3c**: Dodano filtr jakości assetu flagi (min. rozmiar PNG), aby monokolorowe placeholdery automatycznie przechodziły na fallback
- [ ] **P14-4**: Test: każdy język z pickera renderuje poprawną ikonę lub fallback
- [ ] **P14-5**: Zweryfikować aktywną ścieżkę assetów klienta (czy build ładuje `data/images/flags/*.png`)
- [ ] **P14-6**: Sprawdzić cache zasobów po stronie klienta i wymusić odświeżenie
- [ ] **P14-7**: Potwierdzić, czy format/rozmiar flag jest akceptowany przez renderer
- [ ] **P14-8**: Wymienić placeholdery jednokolorowe na pełne flagi (część nowych PNG wygląda jak plansze testowe)

---

## PROBLEM P15: Uszkodzone znaki w nazwach języków (Español/Português) + glify

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

## PROBLEM P20: NPC Bozo — błąd składni przy starcie serwera ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

### Analiza
- Przy starcie serwera parser Lua wywalał błędy w `data-otservbr-global/npc/bozo.lua` (niedomknięte/zbędne przecinki i błędna struktura jednego wpisu `config`).
- Dodatkowo część wpisów miała samo `i18nKey` bez bezpiecznego fallbacku `text`, co groziło błędami w ścieżkach dialogowych.

### Zadania
- [x] **P20-1**: Usunięto błędy składni (`},`) i poprawiono strukturę tabeli `config`
- [x] **P20-2**: Naprawiono blok `config[30]` (prawidłowe zagnieżdżenie `text = { [3] = ... }`)
- [x] **P20-3**: Dodano fallback normalizujący `i18nKey -> text[1]/text[2]` dla `config`
- [x] **P20-4**: Dodano analogiczny fallback dla `jesterOutfit`
- [ ] **P20-5**: Test runtime: pełny start serwera + dialog Bozo bez błędów questline

---

## PROBLEM P21: Konsola/czat — wpisywany tekst ma zły baseline i jest ucinany ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

### Analiza
- Retest potwierdza, że litery specjalne są wpisywane, ale wizualnie "opadają" i nie mieszczą się w wysokości pola.
- To wygląda na błąd pionowego pozycjonowania (baseline/ascent/descent), paddingu albo clip rect w polu wejścia.
- Problem dotyczy UI inputu, a nie parsera klawiatury.

### Zadania naprawcze (szczegółowo)
- [x] **P21-1**: Zidentyfikowano widget i style (`modules/game_console/console.otui` + `data/styles/40-console.otui`)
- [x] **P21-2**: Zweryfikowano konfigurację font/box i ujednolicono parametry wysokości/paddingu
- [x] **P21-3**: Podniesiono wysokość inputu (`height: 24`) + dodano `padding` i `text-offset`
- [x] **P21-4**: Dostosowano clipping/baseline etykiet konsoli (`ConsoleLabel`/`ConsolePhantomLabel` height + padding)
- [ ] **P21-5**: Dodać test regresji dla PL/ES/RU w input: brak opadania i brak ucinania.
- [ ] **P21-6**: Potwierdzić poprawne zachowanie na Windows i Linux po tej samej konfiguracji fontu.

---

## PROBLEM P22: Książka — nie można zaznaczyć/skopiować treści (działa tylko nagłówek) ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

### Analiza
- Użytkownik nie może zaznaczyć treści w obszarze tekstowym książki; zaznacza się tylko element u góry.
- Oczekiwane zachowanie: możliwość zaznaczania i kopiowania tekstu treści książki.
- Problem dotyczy interakcji/selectability widgetu treści.

### Zadania naprawcze (szczegółowo)
- [x] **P22-1**: Potwierdzono widget treści i ustawiono `selectable: true` + `focusable: true` w `textwindow.otui`
- [ ] **P22-2**: Zweryfikować, czy warstwa nadrzędna (panel/overlay) nie przechwytuje myszy.
- [x] **P22-3**: Poprawiono hit-test pozycji kursora dla TTF w `uitextedit.cpp` (multiline + scroll + mapowanie wrapped text)
- [x] **P22-4**: Wymuszono focus/cursor setup także dla trybu read-only (`textwindow.lua`)
- [ ] **P22-5**: Test: zaznaczenie myszą i kopiowanie treści działa niezależnie od języka.

---

## PROBLEM P23: Książka — reguła tłumaczenia czarów (komenda stała, nazwa lokalizowana) ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

### Analiza
- W treści książki komendy i nazwy czarów są aktualnie mieszane/błędnie lokalizowane.
- Wymaganie biznesowe:
  - komenda (np. `exura dis`) ma pozostać bez zmian,
  - nazwa czaru (np. `Practice Healing`) ma być przetłumaczona.
- To jest zadanie jakości i18n contentu; worker docelowo może wspierać, ale teraz robimy to ręcznie/proceduralnie.

### Zadania naprawcze (szczegółowo)
- [x] **P23-1**: Zidentyfikowano źródło i punkt sklejania linii (`data/scripts/actions/items/spellbook.lua`)
- [x] **P23-2**: Wdrożono regułę renderu: `<words> - <name> : <mana>`
- [x] **P23-3**: Zablokowano tłumaczenie segmentu komendy (`spell.words` pozostaje bez zmian)
- [x] **P23-4**: Włączono tłumaczenie wyłącznie segmentu nazwy czaru (`getTranslatedSpellName`)
- [x] **P23-5**: Dodano fallback/walidację (gdy brak poprawnego tłumaczenia, używana jest nazwa źródłowa)
- [ ] **P23-6**: Test: kilka książek, różne linie czarów, PL/EN — komenda identyczna, nazwa lokalna poprawna.

---

## PROBLEM P24: Czat lokalny (i inne kanały) — wiadomości wychodzą poza obramówkę ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

### Analiza
- Na screenie 7 widać, że wyświetlane wiadomości nie mieszczą się idealnie w polu listy czatu.
- Problem może dotyczyć szerokości kolumny tekstu, paddingów, wrapu, metryk fontu i/lub auto-resize kontenera.
- Potencjalnie ten sam błąd może występować w `NPC`, `World Chat`, `Advertising`.

### Zadania naprawcze (szczegółowo)
- [x] **P24-1**: Wymuszono dynamiczne dopasowanie szerokości etykiet do `consoleBuffer` (`fitLabelWidthToBuffer` + hook `onGeometryChange` dla tabów i panelu read-only)
- [x] **P24-2**: Dodano wymuszone zawijanie długich tokenów bez spacji (`forceWrapLongUnbrokenTokens` w `console.lua`)
- [x] **P24-3**: Rozszerzono wrap o tokeny UTF-8 (PL/ES/RU), bez rozbijania znaków wielobajtowych
- [x] **P24-4**: Zmiana działa w `addTabText`, więc obejmuje kanały renderowane przez wspólną ścieżkę konsoli
- [ ] **P24-5**: Dodać testy wizualne: krótkie i długie wiadomości, PL diakrytyki, różne kanały.

---

## PROBLEM P25: Cyklopedia/House — artefakty debug w etykietach + hardcoded EN ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

### Analiza
- W `modules/game_cyclopedia/tab/house/house.lua` znaleziono artefakty debug doklejane do nazw (`asdasd`, `22222`, `888`, `44444`, `9999`, `99889`, `44242`).
- Część etykiet w sekcji aukcji była hardcoded po EN (`Highest Bidder`, `End Time`, `Highest Bid`) mimo istniejących kluczy i18n.

### Zadania naprawcze (szczegółowo)
- [x] **P25-1**: Usunięto artefakty debug ze wszystkich formularzy House (reject/accept/cancel transfer, transfer, move out, bid)
- [x] **P25-2**: Podmieniono hardcoded EN etykiet aukcji na klucze `otclient_modules.house.tr_14/tr_15/tr_16`
- [ ] **P25-3**: Retest UI zakładki House (wszystkie flow formularzy) po nowej kompilacji

---

## PROBLEM P26: Opcje gry — niespójne runtime i18n (EN fallback/hardcoded) ⚠️ POPRAWKA W KODZIE / CZEKA RETEST

### Analiza
- Część nowych kluczy i18n była dodana do `i18n/en/pl/*.json`, ale brakowało ich w runtime locale `game_i18n_en.lua` / `game_i18n_pl.lua`.
- W `general_otui` były błędne mapowania kluczy opóźnień (`tr_2`/`tr_4`), co powodowało nieprawidłowe etykiety.
- `styles/graphics/effects.otui` nadal zawierał hardcoded EN dla `ambientLight` i `shadowFloorIntensity`.

### Zadania naprawcze (szczegółowo)
- [x] **P26-1**: Zsynchronizowano runtime locale EN/PL o nowe klucze (`data_options.tr_8..tr_13`, `options.crosshair_*`, `options.antialias_*`, `options.floor_mode_*`, `options.frames_*`, `items_otui.quickloot_*`, `items_otui.vocation_short`)
- [x] **P26-2**: Poprawiono mapping `general_otui.tr_2` (floor change) i `general_otui.tr_4` (teleport) w runtime locale EN/PL
- [x] **P26-3**: Usunięto hardcoded EN z `effects.otui` (`ambientLight`, `shadowFloorIntensity`, `floorFading`) na rzecz kluczy `otclient_modules.data_options.*`
- [ ] **P26-4**: Retest UI opcji (PL/EN) po kompilacji: brak EN fallback i poprawne etykiety sliderów/comboboxów

---

## Priorytetyzacja — kolejność naprawy

### Faza 1 — KRYTYCZNE (blokuje gameplay)
1. **P21** — Input czatu: baseline/ucinanie liter diakrytycznych
2. **P24** — Overflow wiadomości w oknie czatu (lokalny + inne kanały)
3. **P22** — Brak zaznaczania/kopiowania treści książki
4. **P23** — Reguła tłumaczeń czarów w książkach (komenda stała, nazwa lokalna)
5. **P14** — Flagi nadal niewidoczne w runtime (mimo dodanych assetów)
6. **P20** — Błąd NPC `Bozo` przy starcie serwera
7. **P26** — Opcje: walidacja runtime i18n po synchronizacji kluczy i mapowania delay

### Faza 2 — WAŻNE (psuje UX)
8. **P8** — `Czatuj dalej` nadal nie dopasowuje szerokości
9. **P6** — `Waga`/`Dusza` nadal nie mieszczą się poprawnie
10. **P16** — Jakość tłumaczeń `Auto reconnect` (EN fallback + `[EN]`)
11. **P1** — Domknięcie testów końcowych po fixie książki (render/scroll)
12. **P12** — Test końcowy brandingu runtime
13. **P15** — Test końcowy nazw języków i glifów
14. **P25** — Retest zakładki House po cleanupie artefaktów i hardcoded EN

### Faza 3 — ULEPSZENIA UI (estetyka)
15. **P2** — NPC żółty dymek (weryfikacja końcowa)
16. **P7** — Sklep button overflow (weryfikacja końcowa)
17. **P9** — Cyklopedia okienka za małe
18. **P3** — Dalsze porządki jakości tłumaczeń NPC
19. **P4** — Zachowanie NPC na niestandardowe frazy (UX dialogu)
20. **P5** — Input Unicode (zamknięte funkcjonalnie, monitoring)

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
| `game_cyclopedia/tab/house/house.lua` | Cyklopedia House (transfer/bid/move out) |
| `game_inventory/inventory.otui` + `.lua` | Ekwipunek (Waga/Dusza) |
| `game_npctrade/npctrade.otui` + `.lua` | Okno handlu NPC |
| `client_entergame/characterlist.otui` + `characterlist.lua` | Auto reconnect (label + layout + toggle) |
| `client_locales/locales.lua` + `locales.otui` | Picker języków (lista, ikony flag, nazwy) |
| `client_bottommenu/bottommenu.otui` | Overlay branding (`OTClient Redemption`) |
| `init.lua` (+ fallbacki `src/framework/core/application.h`, `src/framework/config.h`) | Nazwa aplikacji/title bar/RPC |
| `data/locales/disabled/es.lua`, `data/locales/disabled/pt.lua` | Uszkodzone diakrytyki nazw języków |
| `data/images/flags/*.png` | Assety flag dla picker języków |
