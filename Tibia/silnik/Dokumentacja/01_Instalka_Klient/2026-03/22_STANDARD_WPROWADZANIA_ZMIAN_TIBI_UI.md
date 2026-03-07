# Standard Wprowadzania Zmian UI (Tibiacom)

Data: 2026-03-06
Cel: unikac kolizji grafiki i "na oko" przesuniec przy zmianach layoutu.

## 1) Zasada nadrzedna
- Najpierw mierzymy grafiki (ramki, chain, buttony, capy), dopiero potem ustawiamy CSS.
- Nie pozycjonujemy po tresci (tekst/naglowek), tylko po koncu grafiki.
- Kazda zmiana sidebar/menu/content musi przejsc smoke PL + EN oraz DPI 100/125/150.

## 2) Pomiar geometrii (obowiazkowy przed zmianami)
- Narzedzie: `php -r` + `getimagesize()` na runtime assets.
- Minimalny zestaw pomiarowy:
  - `images/general/box-top.gif`
  - `images/general/box-bottom.gif`
  - `images/general/chain.gif`
  - `images/menu/button-background.gif`
  - `images/menu/label-*.gif`
  - `images/global/buttons/sbutton.gif`
- Wyniki wpisujemy do zmiennych CSS (sekcja `:root`) i dopiero te zmienne uzywamy w layout.

### Snapshot pomiarowy (2026-03-06, runtime `/var/www/html`)
- `box-top.gif`: `180x12`
- `box-bottom.gif`: `180x12`
- `chain.gif`: `7x10`
- `button-background.gif`: `170x32`
- `button-background-over.gif`: `170x32`
- `label-account.gif`: `116x22`
- `loginbox-textfield-background.gif`: `160x13`
- `sbutton.gif`: `135x25`

Komenda referencyjna:
```bash
php -r '$imgs=["/var/www/html/templates/tibiacom/images/general/box-top.gif","/var/www/html/templates/tibiacom/images/general/box-bottom.gif","/var/www/html/templates/tibiacom/images/general/chain.gif","/var/www/html/templates/tibiacom/images/menu/button-background.gif","/var/www/html/templates/tibiacom/images/menu/button-background-over.gif","/var/www/html/templates/tibiacom/images/menu/label-account.gif","/var/www/html/templates/tibiacom/images/loginbox/loginbox-textfield-background.gif","/var/www/html/templates/tibiacom/images/global/buttons/sbutton.gif"]; foreach($imgs as $p){$s=@getimagesize($p); echo basename($p),"\t",($s?($s[0]."x".$s[1]):"MISSING"),"\n";}'
```

## 3) Geometry Contract (left sidebar)
- `--tb-left-col-outer-width`: szerokosc capa (box top/bottom).
- `--tb-left-col-inner-width`: szerokosc przycisku/menu body.
- `--tb-left-col-cap-height`: wysokosc capa top/bottom.
- `--tb-left-col-chain-width`: szerokosc chain.
- `--tb-left-col-inset`: offset panelu od kolumny.

Aktualny source of truth:
- `canary_test/html_copy/templates/tibiacom/basic.css`: sekcja `:root` (tokeny geometrii).
- `canary_test/html_copy/templates/tibiacom/basic.css`: sekcja `#Loginbox`, `#Loginbox.GlobalLoginSidebar`, `#Menu`, `#MenuTop`, `#MenuBottom`.

Regula:
- `#Loginbox`, `#Menu`, `#MenuTop`, `#MenuBottom`, `.MenuButton` maja byc liczone z tych samych zmiennych.
- `#MenuTop` musi byc pozycjonowany od wysokosci capa (`top = -cap-height`), nie od arbitralnego px.

## 4) Sidebar Login (wymagania)
- Zachowac stylistyke tibiacom: grafiki ramek, chain, cap top/bottom.
- Napisy login/create/logout jako tekst i18n (nie obrazki-fonty).
- Dla zalogowanego: przyciski konta + aktywny profil globalny + switch all/classic74/modern.
- Dla niezalogowanego: login + create account + hint konta globalnego.

Aktualne pliki implementacyjne:
- Markup/flow: `canary_test/html_copy/templates/tibiacom/index.php`
- Style/layout: `canary_test/html_copy/templates/tibiacom/basic.css`
- Locale PL: `canary_test/html_copy/system/locale/pl/main.php`
- Locale EN: `canary_test/html_copy/system/locale/en/main.php`

## 5) i18n dla grafik menu
- Etykiety menu typu `spolecznosc`, `forum`, `biblioteka` wymagaja wariantow assetow per jezyk.
- Naming convention:
  - `label-forum.en.gif`
  - `label-forum.pl.gif`
- Fallback:
  - aktywny jezyk -> `en` -> domyslny legacy asset.

Pliki, ktore trzeba objac przy K165:
- `canary_test/html_copy/templates/tibiacom/index.php` (sposob budowania URL labeli menu)
- `canary_test/html_copy/templates/tibiacom/images/menu/` (asset pack per jezyk)
- `canary_test/html_copy/system/locale/pl/main.php` i `canary_test/html_copy/system/locale/en/main.php` (etykiety pomocnicze/fallback)

## 6) Kolejnosc wdrozen (obowiazkowa)
1. Fix clipping/padding krytycznego ekranu (start od highscores).
2. Geometria i wspolne zmienne CSS.
3. Sidebar login v3.
4. i18n grafik menu.
5. Status serwerow konfigurowalny (global + per-world).
6. QA matrix + screenshot diff.

## 7) QA Gate (minimum)
- Trasy: `/`, `/index.php/highscores`, `/index.php/online`, `/index.php?subtopic=accountmanagement`.
- Jezyki: `pl`, `en`.
- DPI/zoom: 100%, 125%, 150%.
- Warunki PASS:
  - brak text-over-border,
  - brak overlap sidebar/menu/content,
  - i18n dziala dla tekstu i grafik etykiet,
  - global profile switch widoczny i klikalny.

## 9) Reuse Checklist (anti-research loop)
- Przed nowa zmiana sprawdz:
  - `22_STANDARD_WPROWADZANIA_ZMIAN_TIBI_UI.md` (ten plik),
  - `23_PLAN_PRACY_AGENTOW_WWW_TIBI.md` (podzial lane'ow, source-of-truth, handoff),
  - `00_START_PRACY_CHECKLISTA.md` (status K163-K168),
  - `01_DZIENNIK_PRAC.md` (ostatni blok K163/K166/K165).
- Nie uruchamiamy ponownego pomiaru assetow, jesli:
  - nie zmienily sie pliki GIF/PNG,
  - nie zmienil sie template path,
  - nie ma nowego wariantu skali/DPI wymagajacego osobnych pomiarow.

## 8) Zakaz zmian "na oko"
- Nie wprowadzamy losowych `-1px/+1px` bez odniesienia do geometry contract.
- Kazda wartosc offsetu musi byc uzasadniona wymiarem grafiki albo jednym z ustalonych tokenow CSS.
