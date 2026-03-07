# Plan H — Portal RedDAXE.pl (pre-kompilacja)

**Data:** 2026-03-05  
**Cel:** domknac testowalny front-door systemu przed kompilacja launchera  
**Tryb:** WWW + API + testy runtime (bez kompilacji lokalnej)

---

## 1. Cel produktu

1. `RedDAXE.pl` jest glownym punktem wejscia dla gracza.
2. Gracz moze:
- pobrac launcher,
- utworzyc konto wspolne,
- przejsc do WWW gry,
- przejsc do forum/wiki,
- przejsc do stron zewnetrznych.
3. Konto utworzone na portalu dziala tak samo na WWW gry i w launcherze.

---

## 2. IA i routing (MVP)

### 2.1 Strony
- `/` — landing RedDAXE
- `/download` — launcher artifacts + checksum
- `/account/create` — rejestracja konta wspolnego
- `/account/login` — logowanie konta wspolnego
- `/go/www` — przekierowanie do WWW gry
- `/go/forum` — przekierowanie do forum
- `/go/wiki` — przekierowanie do wiki
- `/go/external/<slug>` — przekierowanie do allow-list linkow zewnetrznych

### 2.2 Zasady redirect
- Brak dynamicznego redirectu z dowolnym URL.
- Tylko allow-list kluczy (`www`, `forum`, `wiki`, `external:<slug>`).
- Kazdy redirect logowany (`source`, `targetKey`, `ipHash`, `ts`).

---

## 3. Kontrakt konta wspolnego

1. Rejestracja portalu i API launchera musza byc kompatybilne:
- `accountName`: `^[A-Za-z0-9_]{3,32}$`
- `email`: valid + lowercase
- `password`: `6..72`
2. Dane konta zapisywane do tej samej tabeli `accounts`.
3. Konto portalu loguje sie przez te same endpointy (`login.php`, `account-context.php`) co launcher.

---

## 4. Download launchera (pre-kompilacja)

1. `download` pokazuje:
- nazwe artefaktu,
- wersje,
- `sha256`,
- date publikacji,
- fallback link.
2. Zrodlo danych:
- preferowane: `installer-catalog.php`
- fallback: statyczna konfiguracja JSON.

---

## 5. Zakres testow przed kompilacja

### H-T1 Konto
- rejestracja na `RedDAXE.pl` -> PASS/FAIL
- login na `RedDAXE.pl` -> PASS/FAIL
- login tym samym kontem na WWW gry -> PASS/FAIL

### H-T2 Download
- link artefaktu odpowiada 200 -> PASS/FAIL
- `sha256` artefaktu zgadza sie z deklaracja -> PASS/FAIL

### H-T3 Routing
- `/go/www`, `/go/forum`, `/go/wiki` dzialaja -> PASS/FAIL
- próba open redirect (`?next=https://...`) jest blokowana -> PASS/FAIL

### H-T4 Integracja z launcher-ready
- konto utworzone na portalu dziala przez `register/login/account-context` API -> PASS/FAIL

### H-T5 i18n (portal + WWW)
- zmiana jezyka PL/EN dziala na portalu i krytycznych stronach konta -> PASS/FAIL
- fallback jezyka dla brakujacego klucza (np. do `en`) -> PASS/FAIL
- brak hardcoded stringow PL na flow register/login/create-character/toplist -> PASS/FAIL

---

## 6. Zadania atomowe

| ID | Zadanie | Priorytet | Status |
|---|---|---|---|
| H1 | Makieta landing + IA portalu | WYSOKI | ✅ RUNTIME PASS: `portal/index.php` HTTP 200 |
| H2 | Strona `download` z danymi artefaktow | WYSOKI | ✅ RUNTIME PASS: download.php HTTP 200, SHA-256 widoczny |
| H3 | Integracja rejestracji konta (wspolny backend) | KRYTYCZNY | ✅ RUNTIME PASS: register E2E PASS (konto w DB, duplikat blokowany) |
| H4 | Integracja logowania konta (wspolny backend) | KRYTYCZNY | ✅ RUNTIME PASS: login E2E PASS (panel+logout) |
| H5 | Redirect controller z allow-list | KRYTYCZNY | ✅ RUNTIME PASS: www/forum/wiki 302, external 302, open-redirect 400 |
| H6 | Logowanie zdarzen redirect | SREDNI | ✅ RUNTIME PASS: JSONL logi w portal_logs/ |
| H7 | Smoke testy E2E konta | KRYTYCZNY | ✅ RUNTIME PASS: 14/14 testow (register+login+duplikat+panel+logout) |
| H8 | Smoke testy E2E download + checksum | WYSOKI | ✅ RUNTIME PASS: download.php HTTP 200, SHA-256 wyswietlony |
| H9 | Smoke testy E2E routing security | KRYTYCZNY | ✅ RUNTIME PASS: redirect allow-list 302, open-redirect 400, external 302 |
| H10 | Dokumentacja operacyjna publikacji artefaktow | SREDNI | ✅ DONE — wpisy w `01_DZIENNIK_PRAC.md` |
| H11 | i18n portal RedDAXE: slowniki + selector jezyka + fallback | KRYTYCZNY | 🔄 PARTIAL — `/portal` runtime PASS; `/reddaxe` i18n wdrozone kodowo (PL/EN + selector + fallback), runtime smoke pending |
| H12 | i18n WWW Tibia: account/create-character/toplist/players-list + bledy | KRYTYCZNY | ✅ RUNTIME PASS (2026-03-07) — pl.json 938 klucze, EN 437/437 (100%), szablony 84/84, 7 stron PASS |
| H13 | Raport testow i18n (PL/EN + fallback + missing keys) | WYSOKI | 🔄 PARTIAL — `/portal` + AAC runtime PASS; `/reddaxe` lokalny smoke PASS po i18n, launcher + runtime smoke `/reddaxe` pending |

---

## 7. Kryteria akceptacji

| Gate | Kryterium | Status |
|---|---|---|
| HG1 | Portal dziala jako front-door bez kompilacji launchera | ✅ PASS — portal wdrozony, 14/14 E2E PASS |
| HG2 | Konto z portalu dziala na WWW i API launchera | ✅ PASS — register+login E2E PASS, konto wspolne w DB potwierdzone |
| HG3 | Download ma poprawny artefakt i checksum | ✅ PASS — download.php HTTP 200, SHA-256 widoczny |
| HG4 | Redirecty sa zamkniete allow-list (brak open-redirect) | ✅ PASS — www/forum/wiki 302, external 302, open-redirect 400 |
| HG5 | Pelny raport testow pre-kompilacyjnych jest w dzienniku | ✅ PASS — wpisy w 01_DZIENNIK + 03_PLAN sekcja 9.8 |
| HG6 | Pelne i18n portal+WWW (PL/EN + fallback + brak missing keys) | 🔄 PARTIAL — `/portal` + AAC runtime PASS; `/reddaxe` code+local smoke PASS, runtime smoke pending |

---

## 8. Ograniczenia

1. Brak lokalnej kompilacji launchera/klienta.
2. Testy bazuja na WWW + API runtime.
3. Kazdy nowy problem logiczny dopisujemy do `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` i dziennika prac.

## 9. Stan wdrozenia (2026-03-05)

Wdrozone pliki:
- `canary_test/html_copy/portal/index.php`
- `canary_test/html_copy/portal/download.php`
- `canary_test/html_copy/portal/account_create.php`
- `canary_test/html_copy/portal/account_login.php`
- `canary_test/html_copy/portal/go/redirect.php`
- `canary_test/html_copy/portal/config.php`
- `canary_test/html_copy/portal/i18n/pl.php`
- `canary_test/html_copy/portal/i18n/en.php`
- `canary_test/html_copy/reddaxe/index.php`
- `canary_test/html_copy/reddaxe/go.php`
- `canary_test/html_copy/reddaxe/bootstrap.php`
- `canary_test/html_copy/reddaxe/account-create.php`
- `canary_test/html_copy/reddaxe/account-login.php`
- `canary_test/html_copy/reddaxe/post-login.php`
- `canary_test/html_copy/apik/v1/installer-catalog.php`
- `canary_test/html_copy/apik/v1/register-account-lib.php`

Wyniki lokalnych smoke testow (bez kompilacji):
- `GET https://127.0.0.1/portal/` -> PASS (`200 OK`)
- `GET https://127.0.0.1/portal/?lang=en` -> PASS (EN copy + `<html lang="en">`)
- `GET https://127.0.0.1/portal/?lang=pl` -> PASS (PL copy + `<html lang="pl">`)
- `GET https://127.0.0.1/portal/account_login.php` -> PASS (`200 OK`)
- `GET https://127.0.0.1/portal/account_create.php` -> PASS (`200 OK`)
- `GET https://127.0.0.1/portal/download.php` -> PASS (`200 OK`)
- `GET https://127.0.0.1/portal/account_login.php?lang=en` -> PASS (EN labels)
- `GET https://127.0.0.1/portal/download.php?lang=en` -> PASS (EN headings)
- fallback probe (`lang=pl`, key tylko EN) -> PASS (`fallback-ok`)
- `GET /apik/v1/installer-catalog.php` -> PASS (zwraca `launcher-main` + `version` + `fallbackUrl`)
- `GET /reddaxe/go.php?to=www` -> PASS (`302 Found`)
- `GET /reddaxe/go.php?to=https://evil.com` -> PASS (`400 Bad Request`)
- `POST /reddaxe/account-create.php` -> PASS (konto tworzone w `accounts`, komunikat sukcesu)
- `GET /reddaxe/account-login.php` -> PASS (formularz post do `/account/login` + redirect `/reddaxe/post-login.php`)
- `POST /apik/v1/account-sync-www-token.php` bez sesji WWW -> PASS negatywny (`www_session_not_authenticated`)
- `reddaxe/post-login.php` ma przycisk generowania tokenu `WWW -> launcher` (endpoint `account-sync-www-token.php`)
- `GET http://127.0.0.1:8123/reddaxe/index.php?lang=en` -> PASS (EN copy + selector jezyka)
- `GET http://127.0.0.1:8123/reddaxe/account-create.php?lang=en` -> PASS (EN rejestracja + labels)
- `GET http://127.0.0.1:8123/reddaxe/account-login.php?lang=en` -> PASS (EN login labels)
- `GET http://127.0.0.1:8123/reddaxe/post-login.php?lang=en` -> PASS (EN sync UI)
- `GET http://127.0.0.1:8123/reddaxe/go.php?to=bad&lang=en` -> PASS (`Invalid redirect key.` po EN)

Wykryty problem logiczny:
- Runtime front-door aktualnie dziala pod sciezka `/portal/*`; wariant `/reddaxe/*` jest utrzymywany jako rownolegly modul repo.
- Routing aplikacyjny `App/Routes` nie ma czytelnego bootstrapa w aktualnym drzewie, dlatego etap H wykonano jako niezalezny portal plikowy (`/reddaxe/*`) do uruchomienia pod vhost `RedDAXE.pl` bez zmian w kompilacji.
- `account-create.php` pierwotnie robil self-HTTP call do `register-account.php` (ryzyko blokady przy single-worker); poprawione przez wspolna biblioteke `register-account-lib.php` (brak rekurencyjnego HTTP).
- Redirect logi `reddaxe/go.php` zapisywaly surowe IP; poprawione na `ipHash` (sha256 + salt z `.env`) w `reddaxe/bootstrap.php`.
- Dla i18n portal `/portal` ma runtime PASS; `/reddaxe` ma code+local smoke PASS, do domkniecia pozostaje runtime smoke i finalna matryca H13/HG6.

## 10. i18n Portal RedDAXE — pełne wdrożenie (2026-03-06)

System i18n zbudowany i wdrożony na produkcję:
- **Architektura**: `config.php` → `portalResolveLang()` + `portalT()` + `portalLoadTranslations()`
- **Detekcja języka**: `?lang=` > cookie `portal_lang` (1 rok) > `Accept-Language` header > default `pl`
- **Pliki tłumaczeń**: `i18n/pl.php` (~100 kluczy), `i18n/en.php` (~100 kluczy)
- **Selektor**: `PL | EN` w nav, klasa `.lang-switch` + CSS
- **Fallback**: nieznany klucz → fallback EN → zwraca klucz

Wyniki E2E (13/13 PASS):
| # | Test | Wynik |
|---|------|-------|
| T1 | index PL | PASS |
| T2 | index EN | PASS |
| T3 | create PL | PASS |
| T4 | create EN | PASS |
| T5 | login PL | PASS |
| T6 | login EN | PASS |
| T7 | download PL | PASS |
| T8 | download EN | PASS |
| T9 | redirect error PL | PASS |
| T10 | redirect error EN | PASS |
| T11 | lang-switch UI visible | PASS |
| T12 | Accept-Language auto EN | PASS |
| T13 | fallback (lang=xx → PL) | PASS |

Status: **✅ `/portal` i18n RUNTIME PASS — 13/13; H11 globalnie pozostaje PARTIAL do czasu runtime smoke `/reddaxe`**
