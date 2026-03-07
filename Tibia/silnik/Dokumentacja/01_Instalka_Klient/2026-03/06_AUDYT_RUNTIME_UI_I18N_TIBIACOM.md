# Audyt Runtime UI/i18n - Legacy `tibiacom` (`/index.php/online`)

**Data:** 2026-03-05 23:32  
**Tryb:** bez kompilacji  
**Zakres:** analiza dlaczego strona nadal jest po angielsku i dlaczego UI jest "uciete"/niespojne

---

## 1. Co potwierdzono

1. Otwierana strona to legacy routing MyAAC:
- URL: `https://127.0.0.1/index.php/online`
- szablon: `templates/tibiacom/*`

2. HTML generuje linki i `base href` na `http://127.0.0.1` mimo wejscia po HTTPS:
- `<base href="http://127.0.0.1/" />`
- wiele linkow/menu i assetow idzie po `http://127.0.0.1/...`

3. Menu nie jest renderowane z kluczy `data-i18n`, tylko z plain-text:
- runtime HTML: `Latest News`, `News Archive`, `Changelog` itd.
- zrodlo: tabela `myaac_menu` (`template=tibiacom`) ma wpisy EN jako zwykly tekst.

4. Runtime i18n loader jest starszy niz w repo:
- runtime: `/var/www/html/resources/i18n/i18n.js` (stary hash)
- repo: `canary_test/html_copy/resources/i18n/i18n.js` (nowszy hash)

5. W legacy widokach sa hardcoded EN:
- np. `system/templates/online.html.twig` ma wiele stalych tekstow (`Players Online`, `World Information`, `Vocation statistics`, itd.)
- dodatkowo `tibiacom` uzywa grafik naglowkow (np. `headline-online.gif`) z tekstem "w obrazie", co nie podlega i18n tekstowemu.

6. Layout `tibiacom` jest z natury stary i sztywny:
- bardzo duzo `position:absolute`, stale wysokosci/szerokosci, `min-width:1000px`, fixed boxes.
- to powoduje "ucinanie" i slabą responsywnosc na nowoczesnych viewportach/skalach DPI.

7. Dodatkowy incydent runtime (wykryty po audycie):
- uszkodzony locale pack `system/locale/pt_br/main.php` (przedwczesne `?>`) emitowal surowe linie `$locale[...]` do HTML stopki.
- objaw: dump `// Menu items ...` widoczny na dole strony.

---

## 2. Root cause (skrot)

1. **Mieszanie HTTPS i HTTP** przez `site_url=http://127.0.0.1` i `base href` -> niespojne ladowanie zasobow.
2. **Brak deployu pelnych zmian runtime** (drift repo vs `/var/www/html`).
3. **Legacy menu z bazy (`myaac_menu`)** zapisane jako EN plain text (bez kluczy i18n).
4. **Legacy template `tibiacom`** ma duzo hardcoded EN + grafiki z tekstem.
5. **Brak jednej decyzji architektonicznej**: albo dopinamy i18n dla legacy, albo migrujemy UI na nowszy stack.

---

## 3. Lista zadan naprawczych (do wykonania)

### Priorytet P0 (blokery widocznosci zmian)

1. `K67` - Ujednolicic canonical URL na HTTPS (`site_url`) i wyeliminowac `http://` z runtime HTML.
2. `K68` - Zrobic kontrolowany deploy plikow repo -> `/var/www/html` (co najmniej i18n loader + pliki WWW) oraz twardy smoke-test po deployu.
3. `K69` - Przebudowac `myaac_menu` dla `tibiacom`: wpisy jako klucze i18n (`<span data-i18n=...>`) albo render przez tlumaczenia serwerowe.

### Priorytet P1 (domkniecie i18n legacy)

1. `K70` - Przejrzec i przerobic hardcoded EN w `system/templates/online.html.twig` + analogiczne legacy strony (`highscores`, `news`, `characters`, itp.).
2. `K71` - Dla elementow tekstowych w obrazkach (`headline-*.gif`) przygotowac strategię:
- wariant A: podmiana grafik per jezyk,
- wariant B: rezygnacja z tekstu w obrazach i przejscie na tekst HTML/CSS.
3. `K72` - Rozszerzyc matryce testow i18n o legacy trasy `index.php/*` (nie tylko nowe endpointy).

### Priorytet P2 (docelowa stabilizacja UI)

1. `K73` - Decyzja: utrzymujemy `tibiacom` (i robimy pelny refactor i18n/UI), czy migrujemy user-facing flow na nowy frontend (portal/reddaxe + nowy layout WWW).
2. `K74` - Jezeli zostaje `tibiacom`: minimalny pakiet UX anti-clipping (stale wysokosci, overflow, spacing dla dluzszych PL stringow, test na 100/125/150% DPI).

---

## 4. Definition of Done (dla tego incydentu)

1. `https://127.0.0.1/index.php/online` nie emituje `http://127.0.0.1/*` w HTML.
2. Menu i glowne sekcje legacy strony sa po polsku przy aktywnym PL.
3. Nie ma "ucinania" krytycznych sekcji w 1920x1080 przy 100% i 125% DPI.
4. Wynik testu i18n legacy jest wpisany do dziennika prac.

---

## 5. Postep wdrozenia (2026-03-05, bez kompilacji)

### Zrobione

1. `K67` ✅
- ustawiono runtime canonical URL na HTTPS (`config.local.php`: `site_url=https://127.0.0.1`)
- smoke `curl https://127.0.0.1/index.php/online`:
  - `<base href="https://127.0.0.1/" />`
  - brak `http://127.0.0.1/*` w HTML

2. `K69` ✅
- menu `tibiacom` w `myaac_menu` przepisane z plain EN na wpisy z kluczami i18n (`<span data-i18n="nav.*">...`)
- runtime HTML ma markery `data-i18n="nav.*"` dla pozycji menu

3. `K70` 🔄 (czesc)
- `system/templates/online.html.twig`: dodane markery i18n dla sekcji status/PvP/skulls/tabel
- `system/templates/highscores.html.twig`: dodane markery i18n dla filtrow/kolumn/paginacji
- `system/templates/news.html.twig`: autor/komentarz przepiete na tlumaczenia serwerowe (`__('news_author')`, `__('news_comment_link')`)
- `system/pages/news.php`: tytuly strony przepiete na tlumaczenia (`menu_latest_news`, `menu_news_archive`)
- slowniki `resources/i18n/en.json` + `pl.json` uzupelnione o brakujace klucze dla highscores
- smoke:
  - `/index.php/online` zawiera m.in. `data-i18n="online.status"` i `data-i18n="status.players"`
  - `/index.php/highscores` zawiera m.in. `data-i18n="highscores.title"` i `data-i18n="tables.filter"`

4. `K68` 🔄 (czesc)
- runtime zsynchronizowany z repo dla krytycznych plikow:
  - `config.local.php`
  - `system/{twig,locale}.php`
  - `system/locale/pt_br/main.php`
  - `system/templates/{online,highscores,news}.twig`
  - `resources/i18n/{i18n.js,en.json,pl.json}`
  - `templates/tibiacom/basic.css`
  - `templates/tibiacom/boxes/templates/highscores.html.twig`
  - `templates/tibiacom/index.php` (`i18n.js` z cache-busting `?v=filemtime`)
 - cache invalidation: `cache_prefix` bump na `myaac_ntbjl75y3` + `cache_engine=none` (etap testow)

5. Incydent `$locale[...]` w stopce ✅
- poprawiono `system/locale/pt_br/main.php` (usuniete przedwczesne `?>`)
- smoke `index.php/news`: dump `// Menu items ...` nie wystepuje

6. Synchronizacja jezyka klient/server ✅
- `resources/i18n/i18n.js` rozszerzono o:
  - sync cookie `locale=<lang>`
  - redirect na `?lang=<lang>` po zmianie jezyka w selectorze JS
- efekt: mniej miksu EN/PL (PHP i frontend dostaja ten sam jezyk)

7. `K74` 🔄 (czesc)
- wdrozone poprawki CSS anti-clipping dla legacy menu:
  - usuniecie twardego obcinania etykiet submenu (`overflow: visible`, `white-space: normal`, `word-break`)
  - dynamiczna wysokosc lancuchow submenu (`height:100%`, `min-height:33px`)
  - wrap dluzszych tresci w `BoxContent` (`overflow-wrap:anywhere`)
  - prawa kolumna (`Players Online` + box highscores) otrzymala korekty font/spacing pod dluzsze napisy

### Otwarte

1. `K70`: pozostale legacy strony (poza `online`/`highscores`/`news`) nadal wymagaja de-hardcode EN.
2. `K71`: naglowki w obrazkach (`headline-*.gif`) nadal bez pelnej strategii per-jezyk.
3. `K72`: brak finalnego raportu PASS/FAIL dla calej matrycy legacy `index.php/*`.
4. `K74`: wymagany manualny test wizualny 100/125/150% DPI (desktop + laptop).

---

## 6. Update 2026-03-06 00:27 (bez kompilacji)

### Zrobione

1. `K68` (deploy drift) - kolejny sync runtime:
- `resources/i18n/i18n.js`
- `templates/tibiacom/{index.php,menus.php,basic.css}`
- `templates/tibiacom/news.featured_article.html.twig`
- `templates/tibiacom/boxes/templates/highscores.html.twig`
- `system/locale/{en,pl}/main.php`

2. `K70` (i18n fallbacki bez JS):
- `templates/tibiacom/index.php`:
  - `status.server_offline_line1/line2` juz z locale (`__()`)
  - `label.template_selector` fallback z locale (`__()`)
  - footer credit fallback z locale (`__()`)
- `templates/tibiacom/menus.php`:
  - fallback label menu zmienione z hardcoded EN na `__()` (`menu_*`)
- `templates/tibiacom/news.featured_article.html.twig`:
  - `read more` fallback z locale (`news_featured_read_more`)

3. `K71` (headline strategy) - postep:
- dynamiczne `headline.php?t=...` aktywne dla:
  - głownego naglowka content (wczesniej),
  - `News Ticker` (wczesniej),
  - `Featured Article` (wczesniej).
- status: strategia wdrozona funkcjonalnie, decyzja docelowa architektury nadal otwarta.

4. `K74` (anti-clipping) - kolejny pakiet CSS:
- `basic.css`:
  - `#RightArtwork #PlayersOnline`: `line-height` + `min-height`
  - `.Themebox`: `min-height` + `height:auto` + `overflow:visible`
  - `#CurrentPollText`: usuniety twardy clipping (`overflow-y:auto`, `height:auto`)
- `highscores.html.twig`:
  - wrapping tekstu i scroll kontenera topki (`overflow-y:auto`, `word-break`)
  - mniejsze offsety PL etykiet, fallback `Poziom` przez `__('col_level')`

5. Ustabilizowanie wyboru jezyka:
- `resources/i18n/i18n.js`:
  - priorytet: `?lang` -> cookie `locale` -> `localStorage` -> `pl`
  - fallback jezyka i slownika ustawiony na `pl` (zamiast `en`)
  - redukuje przypadki losowego EN przy starcie przegladarki.

### Walidacja

1. `php -l` PASS:
- `templates/tibiacom/index.php`
- `templates/tibiacom/menus.php`
- `system/locale/en/main.php`
- `system/locale/pl/main.php`

2. `node --check` PASS:
- `resources/i18n/i18n.js`

3. smoke (`curl`) PASS:
- `index.php/news?lang=pl`: tytul PL, `Skomentuj tego newsa`, `Szablon:` fallback PL
- `index.php/news?lang=en`: tytul EN, fallback EN
- brak dumpu `// Menu items ...` w HTML.

### Otwarte po update

1. `K68`: fizyczny purge `system/cache/myaac_*` na runtime zablokowany przez uprawnienia (`Permission denied`), ale etap testowy dziala na `cache_engine=none`.
2. `K72`: nadal brak finalnej matrycy PASS/FAIL dla wszystkich tras legacy `index.php/*`.
3. `K74`: nadal wymagany manualny test wizualny DPI 100/125/150% na przegladarce.

---

## 7. Update 2026-03-06 00:41 (logic fixes: EN/PL mix)

### Nowo wykryty blad logiczny

1. W `system/templates/online.html.twig` ten sam klucz `data-i18n="page.section"` byl uzyty dla kilku roznych naglowkow (`World Information`, `Players Online`, `Search Character`), co powodowalo semantyczny konflikt tlumaczen.
2. W `system/pages/highscores.php` zdarzaly sie rekordy z linkiem `href="(error)"` dla postaci modern przy fallbacku `getPlayerLink`.

### Naprawy

1. `online` + `characters.form`:
- rozdzielone klucze sekcji: `online.world_information`, `online.players_online_heading`, `online.search_character`
- fallbacki EN podmienione na locale (`__()`) dla etykiet krytycznych

2. `highscores`:
- fallbacki EN filtrow/naglowkow/pagera podmienione na locale (`__()`)
- nazwy serwerow i skilli z `system/pages/highscores.php` podmienione na klucze locale (`server_*`, `category_*`)
- vocations (`None/Sorcerer/...`) lokalizowane do locale
- fallback linku gracza: jesli `getPlayerLink` zwraca `(error)`, URL budowany przez `characters/<name>`

3. Slowniki:
- `system/locale/{en,pl}/main.php`: uzupelnione o klucze online/highscores/tables/vocations
- `resources/i18n/{en,pl}.json`: uzupelnione o klucze `online.*` dla nowych naglowkow/etykiet

### Efekt runtime (smoke)

1. `/index.php/online?lang=pl`:
- `Informacje o świecie`, `Gracze online`, `Szukaj postaci`, `Nazwa postaci`, `sortuj`
2. `/index.php/highscores?lang=pl`:
- `Wybierz umiejętność/profesję/serwer`, `Pozycja`, `Punkty`, `[WSZYSTKIE]`
3. Brak `href="(error)"` w topce.

---

## 8. Update 2026-03-06 01:12 (K76-K79: create-account CSRF + rules 3-mode + i18n)

### Zgloszone problemy (runtime)

1. `Create Account` z `account/manage` otwieral biala strone:
- `Request has been cancelled due to security reasons - token is invalid.`
2. Login box pokazywal placeholder:
- `Nowy na {{server}}?`
3. Brak 3 dzialajacych wariantow zasad (`all/classic74/modern`) w flow rejestracji.
4. Mix EN/PL na stronach konta/rejestracji.

### Naprawy wdrozone

1. `K76` - CSRF false-positive:
- `system/pages/account/create.php`:
  - `csrfProtect()` uruchamiany tylko dla submitu (`save=1`), nie dla zwyklego wejscia GET.
- `templates/tibiacom/account.login.html.twig`:
  - przycisk `Create Account` zmieniony z `POST` na `GET` (nawigacja, nie akcja mutujaca).
- `system/functions.php`:
  - komunikat `token is invalid` zlokalizowany (`csrf_invalid_token` + `back`).

2. `K77` - `Tibia Rules` 3 opcje:
- dodano `system/pages/rules.php` + `system/templates/rules.mode.html.twig`
  - tabs: `all`, `classic74`, `modern`
  - fallback: gdy brak dedykowanej tresci, render global `rules`
  - diagnostyka: pokazywane `Źródło zasad: <code>...</code>`
- dodano route override:
  - `system/routes.php`: `rules` + `rules/{mode}` (priority 50)
- fallback bez zaleznosci od cache route:
  - `system/router.php`: wymuszenie mapowania URI `rules`/`index.php/rules` -> `subtopic=rules`
  - `templates/tibiacom/index.php`: menu `Regulamin` prowadzi do `?subtopic=rules`
  - `account.create` linkuje bezposrednio do `?subtopic=rules&mode=*`

3. `K78` - i18n konto/rejestracja:
- `system/templates/account.create.html.twig`:
  - hardcoded EN etykiet/form zastapione locale `__()`
  - sekcja akceptacji regulaminu rozszerzona o 3 linki mode
- `system/templates/account.create.js.html.twig`:
  - komunikaty walidacji JS przepiete na locale
- `templates/tibiacom/account.login.html.twig`:
  - `Nowy na $SERVER$` renderowany po stronie serwera (bez `{{server}}`)
- `system/pages/account/base.php` + `system/functions.php`:
  - lokalizacja fallback labeli loginu (`Email/Account Name/Number`, `or`).

4. Slowniki:
- `system/locale/en/main.php`
- `system/locale/pl/main.php`
- dodane klucze dla:
  - create-account form + JS errors
  - rules mode/fallback/source
  - csrf invalid token
  - account login dynamic heading + labels.

### Runtime deploy + walidacja

1. Sync do `/var/www/html` wykonany dla:
- `system/pages/{account/create.php,account/base.php,rules.php}`
- `system/templates/{account.create.html.twig,account.create.js.html.twig,rules.mode.html.twig}`
- `templates/tibiacom/{account.login.html.twig,index.php}`
- `system/{functions.php,routes.php,router.php}`
- `system/locale/{en,pl}/main.php`

2. Smoke PASS:
- `/index.php/account/manage?lang=pl`:
  - naglowek: `Nowy na Tibia 7.4 test?` (bez `{{server}}`)
  - `Create Account` form `method=get`
- `/index.php/account/create?lang=pl`:
  - brak `token is invalid` przy zwyklym wejściu
  - checkbox: `Akceptuję regulamin ...`
  - 3 linki zasad: `all/classic74/modern`
- `/index.php?subtopic=rules&mode=classic74&lang=pl`:
  - tabs 3-mode widoczne
  - `Źródło zasad: rules`
- `/index.php/rules?mode=modern&lang=pl`:
  - fallback routera dziala, tabs 3-mode widoczne.

3. Ograniczenia:
- purge cache runtime nadal zablokowany:
  - `Permission denied` dla `/var/www/html/system/cache/route.cache` i `myaac_*`.
- mimo to hotfix działa przez:
  - `?subtopic=rules` fallback i nadpisanie linku menu.
