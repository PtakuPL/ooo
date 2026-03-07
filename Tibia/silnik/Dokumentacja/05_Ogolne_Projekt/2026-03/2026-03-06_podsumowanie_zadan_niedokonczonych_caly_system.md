# Podsumowanie Zadan Niedokonczonych z Dokumentacji

**Data podsumowania:** 2026-03-06  
**Zakres przegladu:** aktywne dokumenty planistyczne, audytowe i checklisty z folderu `Dokumentacja/01_Instalka_Klient/2026-03` oraz backlog glowny projektu  
**Cel:** zebrac w jednej punktowej liscie zadania, ktore nadal nie sa domkniete i wymagaja dalszej pracy, deployu, smoke testu, E2E albo finalnej decyzji architektonicznej.

## 1. Jak czytac ten dokument

1. Na liste trafiaja zadania ze statusem `TODO`, `PARTIAL`, `SPEC READY`, `DRAFT READY`, `runtime pending`, `smoke pending`, `E2E pending`, `GO/NO-GO pending` albo rownowaznym.
2. Jezeli kod jest gotowy, ale dokumentacja sama wskazuje brak deployu, runtime smoke, finalnego gate albo E2E, to zadanie nadal jest tutaj traktowane jako niedokonczone.
3. Ten dokument jest para do pliku `2026-03-06_podsumowanie_wykonanych_zadan_ostatni_tydzien.md`, ktory zbiera rzeczy juz wykonane.

## 2. SCALONA LISTA PUNKTOWA - zadania niedokonczone

### Konto globalne, SSO i logowanie

1. Domknac finalne runtime E2E konta globalnego na pelnej sciezce launcher -> RedDAXE -> WWW -> launcher.
2. Domknac runtime E2E natywnego logowania launchera email+haslo -> `sessionKey` bez recznego wklejania danych.
3. Domknac runtime E2E natywnej rejestracji konta w launcherze z auto-login i fallbackiem.
4. Domknac runtime E2E ujednoliconej rejestracji WWW/API po deployu runtime.
5. Zweryfikowac runtime fallback komunikatow launcher+WWW przy wygaslej sesji lub tokenie.
6. Ustawic sekrety i callback URL-e dla Google OAuth w runtime.
7. Ustawic sekrety i callback URL-e dla Facebook OAuth w runtime.
8. Ustawic sekrety i callback URL-e dla Steam/OpenID w runtime.
9. Wykonac pelne testy E2E z realnym loginem providerow social.
10. Domknac polityke linkowania kont social, w tym merge policy i parity dla wszystkich providerow.
11. Domknac finalny runtime gate dla portalu `RedDAXE.pl` jako front-doora systemu.
12. Domknac finalny login WWW dla kont utworzonych na `RedDAXE.pl`.
13. Domknac finalny runtime gate dla bezpiecznych przekierowan RedDAXE po deployu.
14. Dopracowac pelna spojnosc brandingu i copy miedzy RedDAXE, WWW gry i launcherem.
15. Przygotowac spec globalnego konta launchera dla wielu gier: `identity` + profile per gra/serwer.
16. Przygotowac security scope multi-game: token tozsamosci vs token profilu gry + audit.

### Architektura portalowa i role globalne

17. Podjac decyzje architektoniczna: PHP MVP zostaje czy portal przechodzi na Python+Django.
18. Zaprojektowac model globalnych rang `Helper/Admin/Multiadmin` per gra/serwer.
19. Zaprojektowac federacje rang do forum i serwisow zewnetrznych.
20. Przygotowac bootstrap projektu Django z `inspectdb`, `StaffRole` i Django Admin.
21. Przygotowac DRF REST API dla rang i integracji zewnetrznych.
22. Przygotowac plan i wykonanie migracji portalu RedDAXE z PHP na Django, jezeli ta droga zostanie wybrana.

### WWW, RedDAXE i i18n

23. Domknac runtime smoke `/reddaxe` po wdrozeniu i18n PL/EN.
24. Domknac finalna matryce i18n E2E dla launcher + `/portal` + `/reddaxe` + WWW Tibia.
25. Domknac pelne i18n WWW Tibia dla wszystkich stron konta, postaci, topki, list i bledow.
26. Dograc brakujace tlumaczenia i fallbacki w remaining legacy Twig/PHP po audycie kolizji kluczy.
27. Rozszerzyc matryce testow i18n o legacy trasy `index.php/*` i raport PASS/FAIL.
28. Podjac decyzje architektoniczna: utrzymanie legacy `tibiacom` vs migracja UI na nowy frontend.
29. Domknac wizualne testy anti-clipping dla `tibiacom` przy DPI 100/125/150.
30. Dokonczyc normalizacje kolidujacych kluczy i18n w legacy Twig.
31. Domknac purge cache i usunac workaround `Permission denied` dla cache runtime.
32. Domknac finalny deploy drift fix, tak aby clean URL i legacy URL byly rowniez w pelni zsynchronizowane po cache purge.
33. Domknac decyzje docelowa dla naglowkow `headline-*.gif`: asset pack per jezyk vs full HTML/CSS.
34. Domknac remaining i18n/copy dla formularzy, bledow i komunikatow user-visible w calym WWW.
35. Zrobic jedna finalna tabele `repo / runtime / E2E / owner` dla obszaru WWW/i18n zgodnie z audytem dokumentacji.

### Dual-server WWW/API/DB

36. ~~Domknac runtime smoke dla `community/highscores` po wdrozeniu splitu `all/classic74/modern`.~~ ✅ DONE 2026-03-07 (200 OK, vocation filter English slugs, pagination fix, column alignment, mode label)
37. Domknac runtime deploy routingu sklepu tak, aby `shop/payment` nie wymagalo dalszego workaroundu. **UWAGA:** `/shop` zwraca 404 runtime 2026-03-07.
38. Zaprojektowac i wdrozyc laczone topki cross-server dla metryk globalnych, np. kills i coins.
39. Przygotowac finalna spec architektury 2 baz serwerow: `global accounts` + `game_classic74` + `game_modern`.
40. Wdrozyc osobne DSN/ENV i bootstrap polaczen dla baz `classic74` oraz `modern` tam, gdzie dokumentacja nadal wskazuje TODO.
41. Wdrozyc warstwe repozytoriow per-serwer z read/write routingiem po `gameMode`.
42. Wdrozyc mapowanie `account_global -> account_world` i provisioning profili serwerowych.
43. Wdrozyc API agregujace dane z 2 baz z oznaczeniem zrodla rekordu.
44. Wdrozyc jeden widok WWW nad 2 bazami z `server switch` i trybem degraded/fallback przy awarii jednej bazy.
45. Wdrozyc dual PDO w CanaryAAC WWW dla `canary_modern` tam, gdzie dokumentacja nadal raportuje braki.
46. Dodac selektor serwera w nawigacji WWW z persystencja sesji wszedzie, nie tylko w juz poprawionych flow.
47. Domknac fizyczna separacje modelu 2 baz tam, gdzie starsze dokumenty nadal raportuja jedna baze gry jako stan otwarty.

### Sklep SMS, platnosci i operacje finansowe

48. Wdrozyc checkout sklepu SMS z twardym kontekstem serwera/bazy i walidacja koszyka per-serwer.
49. Domknac callback SMS: idempotencja, podpis providera, anti-replay i routing creditu do poprawnej bazy.
50. Wykonac runtime E2E dla callbackow platnosci po realnym deployu i sekretach providerow.
51. Dokoaczyc finalne signature hardening dla platnosci.
52. Wdrozyc widok historii zakupow `all` z filtrami per-serwer i audit trail UI/read-model.
53. Wdrozyc worker/cron do rekonsyliacji transakcji provider <-> DB.
54. Wdrozyc monitoring i alerty dla DB health, callback SMS errors, duplicate txn i lag rekonsyliacji.
55. Wykonac matryce testow E2E bez kompilacji dla register/login/create-character/shop-sms na 2 bazach.
56. Wykonac plan migracji danych 1-baza -> 2-bazy wraz z rollbackiem, nie tylko na poziomie specyfikacji.
57. Domknac operacyjny runbook dla onboarding nowego serwera/bazy i procedur awaryjnych do poziomu gotowego playbooka runtime.

### Serwer Canary i model dwoch swiatow

58. Domknac decyzje pipeline: jedno binary + dwa configi czy dwa osobne artefakty serwera.
59. Utrwalic finalny kontrakt `mode -> world -> worldId -> account/character` na wszystkich warstwach bez remaining wyjątkow runtime.
60. Domknac finalne testy integracyjne dla obu serwerow po kompilacji artefaktow GHA.
61. Domknac wszystkie remaining pozycje z planu serwera `10_PLAN_SERWER_CANARY_74_VS_MODERN.md`, ktore nadal maja status `W trakcie` lub `Otwarte`.

### Launcher i instalka gracza

62. Zwalidowac finalny artefakt paczki gracza po GHA pod katem allowlist/denylist i finalnego layoutu release.
63. Uruchomic i potwierdzic `package lint` oraz security scan na realnym artefakcie GHA, nie tylko na poziomie kodu workflow.
64. Domknac bootstrap first-run na realnym artefakcie i potwierdzic fail-closed w runtime.
65. Wdrozyc update atomowy z rollbackiem oraz retry/resume w instalce.
66. Wdrozyc `repair mode`, `safe reset` i `support bundle` dla instalki.
67. Domknac runtime E2E SSO: launcher -> instalka/klient bez ponownego logowania.
68. Domknac runtime E2E gatingu, ktory blokuje start gry bez postaci na wybranym serwerze.
69. Domknac runtime E2E deep-link `create-character` i powrotu do launchera z zachowanym `mode`.
70. Zweryfikowac config hardening `dev/stage/prod`, schema validation i HTTPS-only na realnym artefakcie release.
71. Wykonac matryce P0 instalki dla Windows 10/11, bez admina, ze spacjami i polskimi znakami w sciezce.
72. Domknac i18n onboardingu instalki/launchera tak, aby nie zostaly mixed strings poza przypadkami fallback.
73. Domknac linki i tresci zasad `all/classic74/modern` w flow instalki po runtime deployu.
74. Uruchomic i zweryfikowac health-check endpointow krytycznych przed kompilacja w realnym gate.
75. Zweryfikowac kompatybilnosc wersji `launcher <-> manifest <-> client` na realnym obiegu wydania.
76. Domknac blokade wielu instancji launchera i cleanup stale lock-file w runtime Windows/Linux.
77. Domknac anti-tamper z kwarantanna i re-download na realnej podmianie plikow krytycznych.
78. Domknac preflight wolnego miejsca i uprawnien zapisu na wszystkich docelowych scenariuszach instalacji.
79. Zamknac gate `G-INS-01..07` na podstawie realnych dowodow PASS/FAIL/BLOCKED.
80. Zamknac gate post-build `PG-INS-01..05` po publikacji artefaktow.
81. Domknac finalna decyzje `go/no-go` dla instalki przed startem workflow GHA.
82. Domknac integracje konta globalnego launcher/WWW/RedDAXE we flow instalki na poziomie runtime E2E.

### Lekki Launcher Bootstrap — NOWE (2026-03-07)

82a. Zaprojektowac i zaimplementowac lekki launcher bootstrap w Rust (<500 KB) — jednorazowy installer pelnego launchera. Plan BL-01..BL-10.
82b. Utworzyc workflow GHA `build-bootstrap-launcher.yml` z weryfikacja rozmiaru. Plan BL-11..BL-14.
82c. Rozszerzyc `installer-catalog.php` o parametr `type=launcher` i dodac wpisy pelnego launchera do katalogu API. Plan BL-15..BL-18.
82d. Zaktualizowac strone pobierania na RedDAXE/WWW: lekki launcher jako glowny download, pelny launcher jako alternatywa portable. Plan BL-19..BL-23.
82e. Wykonac E2E test calej sciezki: lekki launcher → pelny launcher → klient → gra. Plan BL-24..BL-29.
82f. Zaktualizowac kontrakty `installer-bootstrap.md` i `installer-catalog.md` o nowy model dwupoziomowy. Plan BL-30..BL-33.
Szczegolowy plan: `Dokumentacja/01_Instalka_Klient/2026-03/25_PLAN_LEKKI_LAUNCHER_BOOTSTRAP.md`
67. Domknac runtime E2E SSO: launcher -> instalka/klient bez ponownego logowania.
68. Domknac runtime E2E gatingu, ktory blokuje start gry bez postaci na wybranym serwerze.
69. Domknac runtime E2E deep-link `create-character` i powrotu do launchera z zachowanym `mode`.
70. Zweryfikowac config hardening `dev/stage/prod`, schema validation i HTTPS-only na realnym artefakcie release.
71. Wykonac matryce P0 instalki dla Windows 10/11, bez admina, ze spacjami i polskimi znakami w sciezce.
72. Domknac i18n onboardingu instalki/launchera tak, aby nie zostaly mixed strings poza przypadkami fallback.
73. Domknac linki i tresci zasad `all/classic74/modern` w flow instalki po runtime deployu.
74. Uruchomic i zweryfikowac health-check endpointow krytycznych przed kompilacja w realnym gate.
75. Zweryfikowac kompatybilnosc wersji `launcher <-> manifest <-> client` na realnym obiegu wydania.
76. Domknac blokade wielu instancji launchera i cleanup stale lock-file w runtime Windows/Linux.
77. Domknac anti-tamper z kwarantanna i re-download na realnej podmianie plikow krytycznych.
78. Domknac preflight wolnego miejsca i uprawnien zapisu na wszystkich docelowych scenariuszach instalacji.
79. Zamknac gate `G-INS-01..07` na podstawie realnych dowodow PASS/FAIL/BLOCKED.
80. Zamknac gate post-build `PG-INS-01..05` po publikacji artefaktow.
81. Domknac finalna decyzje `go/no-go` dla instalki przed startem workflow GHA.
82. Domknac integracje konta globalnego launcher/WWW/RedDAXE we flow instalki na poziomie runtime E2E.

### Integracja globalna i gate kompilacyjny

83. Zamknac gate integracyjny `G-INT` i matryce `T-INT-01..12` dla launcher + WWW + Canary.
84. Zamknac finalny gate pre-kompilacja `G0-G7` z jednaznaczna decyzja START GHA.
85. Uruchomic pelna kompilacje GHA dla serwera, launchera, klienta i paczki gracza dopiero po domknieciu wszystkich gate'ow.
86. Wykonac post-build E2E dla loginu globalnego, tworzenia postaci na 2 serwerach, update launchera i startu klienta.
87. Zamknac finalna decyzje `START GHA` po gate globalnym, installerowym i integracyjnym.
88. Zapisac jeden zbiorczy raport `go/no-go` po faktycznym przejsciu wszystkich gate'ow.

### Dokumentacja, operacje i porzadek source-of-truth

89. Ujednolicic statusy we wszystkich aktywnych dokumentach do jednego formatu `repo / runtime / E2E / owner`.
90. Rozdzielic w dokumentacji rzeczy historyczne/specyfikacyjne od faktycznie wdrozonych, szczegolnie w plikach `launcher+rust*.md`.
91. Podzielic ogromny dokument `plan_zabezpieczenia_klienta_i_serwera.md` na mniejsze source-of-truth po zakonczeniu aktualnego etapu.
92. Utrzymac aktualizacje checklist i dziennika po kazdym kolejnym batchu `INS-P0`, `INT-P0` i gate'ow.

### Nowe problemy runtime wykryte 2026-03-07

93. `/community/houses` zwraca 404 — brak routingu lub brakujacy plik strony houses.
94. `/shop` zwraca 404 — brak routingu sklepu w runtime.
95. Online page — dual modern query emituje blad `Unknown column 'a.country' in SELECT` dla `canary_modern` — tabela `accounts` w `canary_modern` nie ma kolumny `country`.
96. Guilds — blad `Unknown column 'description' in SELECT` w `/community/guilds` — tabela `guilds` moze nie miec kolumny `description` (lub roznica schema miedzy bazami). Strona zwraca 200 na 2026-03-07 (prawdopodobnie graceful degradation lub cache).
97. Highscores vocation dropdown — etykiety vocacji w dropdown pokazuja surowe polskie nazwy z configa (Czarnoksiężnik, Paladyn) zamiast przetłumaczonych nazw z `__()`, bo warunki `{% if vocationLabel == 'Sorcerer' %}` w template nigdy nie matchuja polskich nazw z config. Nie blokuje — config i tak jest po polsku, ale docelowo warto poprawic na lookup po indeksie.

## 3. Najwazniejsze blokery do dalszej pracy

1. Finalny runtime E2E konta globalnego i SSO na calej sciezce launcher <-> WWW <-> RedDAXE.
2. Finalne gate'y `G-INS`, `G-INT` i globalny `START GHA`.
3. Nierozstrzygnieta architektura 2 baz i czesci funkcji cross-server ponad 2 DB.
4. Niedomkniete runtime smoke i E2E dla instalki gracza oraz realnych artefaktow GHA.
5. Niedomkniete i18n/UX dla legacy WWW oraz finalny stan `/reddaxe`.
6. **NOWE:** `/community/houses` i `/shop` daja 404 runtime.
7. **NOWE:** Online page emituje blad `a.country` dla `canary_modern` — brakujaca kolumna w schema modern.

## 4. Zrodla podsumowania

1. `Dokumentacja/01_Instalka_Klient/2026-03/00_START_PRACY_CHECKLISTA.md`
2. `Dokumentacja/01_Instalka_Klient/2026-03/03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`
3. `Dokumentacja/01_Instalka_Klient/2026-03/04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md`
4. `Dokumentacja/01_Instalka_Klient/2026-03/05_PLAN_SKLEP_SMS_2_BAZY.md`
5. `Dokumentacja/01_Instalka_Klient/2026-03/06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md`
6. `Dokumentacja/01_Instalka_Klient/2026-03/07_PLAN_JUTRO_DZIEN_KOMPILACJI.md`
7. `Dokumentacja/01_Instalka_Klient/2026-03/08_PLAN_INSTALKA_JUTRO_DETALE.md`
8. `Dokumentacja/01_Instalka_Klient/2026-03/09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md`
9. `Dokumentacja/01_Instalka_Klient/2026-03/10_AUDYT_DOKUMENTACJI_I_BRAKOW_2026-03-06.md`
10. `Dokumentacja/01_Instalka_Klient/2026-03/10_PLAN_SERWER_CANARY_74_VS_MODERN.md`
11. `Dokumentacja/01_Instalka_Klient/2026-03/11_PLAN_BAZY_DANYCH_SYNC_TRIGGERY.md`
12. `Dokumentacja/01_Instalka_Klient/2026-03/12_PLAN_API_ENDPOINTY_POPRAWKI.md`
13. `Dokumentacja/01_Instalka_Klient/2026-03/13_PLAN_KONTO_GLOBALNE_UNIFIED.md`
14. `Dokumentacja/01_Instalka_Klient/2026-03/14_PLAN_LAUNCHER_TAURI_RUST.md`
15. `Dokumentacja/01_Instalka_Klient/2026-03/15_PLAN_INSTALKA_KLIENT_PACZKA.md`
16. `Dokumentacja/01_Instalka_Klient/2026-03/16_PLAN_WWW_REDDAXE_I18N.md`
17. `Dokumentacja/01_Instalka_Klient/2026-03/17_MASTER_CHECKLIST_KOMPILACJA.md`
18. `Dokumentacja/01_Instalka_Klient/2026-03/18_RUNBOOK_SUPPORT_INSTALKA_TOP_PROBLEMY.md`
19. `Dokumentacja/01_Instalka_Klient/2026-03/19_CHECKLISTA_PUBLIKACJI_PACZKI_GRACZA.md`
20. `Dokumentacja/01_Instalka_Klient/2026-03/20_CHECKLISTA_MONITORING_24H_PO_PUBLIKACJI.md`
21. `Dokumentacja/01_Instalka_Klient/2026-03/21_MAPA_KODOW_BLEDOW_INSTALKI_SUPPORT_KB.md`
22. `Dokumentacja/01_Instalka_Klient/2026-03/02_DZIENNIK_BUILDOW_GHA.md`
23. `Dokumentacja/01_Instalka_Klient/2026-03/plan_zabezpieczenia_klienta_i_serwera.md`
24. `Dokumentacja/05_Ogolne_Projekt/2026-03/2026-03-06_master_backlog_caly_system.md`
25. `Dokumentacja/01_Instalka_Klient/2026-03/24_PLAN_WWW_TIBI_MASTER_ZADANIA.md`
26. `Dokumentacja/01_Instalka_Klient/2026-03/2026-03-06_naprawa_instalki_dev_gracz.md`
27. `Dokumentacja/01_Instalka_Klient/2026-03/03_AUDYT_PRAC_COPILOT_CLAUDE.md`

## 5. Dodatkowo Znalezione W Kolejnym Przegladzie

1. Dodac brakujaca trase FastRoute dla `/latestnews` i usunac 404 tej strony.
2. Naprawic `title_not_found` przez przeniesienie `data-i18n-title` na `<html>` oraz ustawienie fallbacku PHP `$title`.
3. Zrobic pelny audyt brakujacych aliasow przy `friendly_urls=false`, w tym `/newsarchive`, `/downloads`, `/community/*`, `/payment` i podobnych tras krytycznych.
4. Domknac strone glowna WWW tak, aby news z DB, `featured article` i `news ticker` dzialaly bez regresji.
5. Zweryfikowac end-to-end login box na WWW: login, redirect do `/account/manage`, welcome state i logout.
6. Domknac flow `Create Account` z Tibia WWW tak, aby redirect do RedDAXE lub formularza tworzenia konta byl spójny i dzialal bez rozjazdu.
7. Dodac w `Account Manage` wyrazna sekcje konta globalnego z nazwa, emailem i premium oddzielona od kont technicznych/postaci.
8. Dodac w `Account Manage` status serwerow `ONLINE/OFFLINE` i liczniki online przy kazdym serwerze.
9. Wdrozyc `profile switch`, czyli przelaczanie kontekstu serwera `classic74/modern` bez wylogowania.
10. Dopiacz filtrowanie strony glownej po `server_mode`, aby newsy mogly byc `all/classic74/modern`.
11. Wdrozyc wyszukiwanie postaci z obu baz z oznaczeniem serwera przy wyniku.
12. Wdrozyc listy gildii per serwer dla `classic74`, `modern` i `all`.
13. Wdrozyc widoki domow per serwer z parametrem `mode`.
14. Podlaczyc `Top Players` w prawym sidebarze do aktywnego `server_mode`.
15. Podlaczyc `Nowy Gracz` i powiazane CTA do wybranego serwera, z preselectem w linku.
16. Domknac kompletnosc `en.json`, tak aby mial te same klucze co `pl.json`.
17. Dokonczyc skan brakujacych kluczy `__()` po stronie locale PHP `main.php` i uzupelnic braki.
18. Domknac i18n formularzy `login`, `create account`, `create character` i `lost password`, lacznie z placeholderami i komunikatami bledow.
19. Przetlumaczyc i ujednolicic komunikaty bledow typu `404`, `invalid password`, `account locked` i inne fallbacki user-visible.
20. Ujednolicic copy w calym serwisie pod nazwy typu `Konto Globalne` i `Utworz postac`, bez miksu z angielskimi etykietami.
21. Dopracowac layout WWW do referencji tibia.com, w tym kompletna prawa kolumne, spacing i proporcje.
22. Domknac `news ticker` jako dzialajacy element UX na stronie glownej.
23. Domknac `featured article` jako dzialajacy element strony glownej.
24. Wykonac pelny test E2E nowego gracza: wejscie na strone -> rejestracja -> login -> create character `classic74` -> widoczna postac.
25. Wykonac pelny test E2E nowego gracza `modern`: rejestracja -> create character -> postac istnieje w poprawnej bazie.
26. Wykonac test E2E `SSO z launchera -> auto-login WWW -> create character -> widoczna postac`.
27. Wykonac test E2E `konto z RedDAXE dziala na WWW`, lacznie z widocznoscia postaci po zalogowaniu.
28. Udostepnic pliki klienta na serwerze WWW jako zrodlo dla manifestu i pierwszego pobrania paczki gracza.
29. Przygotowac i uruchomic `generate_manifest.php`, aby generowal podpisany manifest plikow klienta z katalogu artefaktu.
30. Przygotowac i utrzymac `CLIENT_FILES_DIR` jako docelowy katalog runtime dla artefaktow klienta po GHA.
31. Wykonac test delta update: zmiana jednego pliku -> nowy manifest -> launcher pobiera tylko ten plik.
32. Domknac `repair mode` na poziomie realnego scenariusza naprawy uszkodzonych plikow klienta i raportu wynikow.
33. Dopiacz uruchamianie klienta z ticketem tak, aby klient pomijal ekran logowania i wracal do launchera przy `expired/invalid ticket`.
34. Potwierdzic, ze paczka gracza nie zawiera plikow developerskich, nie tylko sekretow.
35. Zamknac test `portable/no-admin`, aby launcher i klient dzialaly w katalogu uzytkownika bez rejestru i uprawnien administratora.
36. Zweryfikowac kompatybilnosc z Windows Defender/AV i ustalic minimalny plan mitigacji dla false positive.
37. Dopiacz launcher UI tak, aby widok po loginie pokazywal pelna karte serwera/postaci z przyciskami `GRAJ` i `Utworz postac`.
38. Domknac blokade `GRAJ` w launcherze, gdy brak postaci na wybranym serwerze, z czytelnym komunikatem i CTA.
39. Wdrozyc auto-login przy starcie launchera na bazie bezpiecznie przechowywanego `sessionKey` i TTL.
40. Domknac natywna rejestracje konta bezposrednio w launcherze jako pelny flow UX, nie tylko warstwe API.
41. Domknac self-update launchera na realnym scenariuszu aktualizacji oraz wymuszeniu `LAUNCHER_MIN_VERSION`.
42. Domknac i18n launchera tak, aby wszystkie teksty po polsku byly kompletne i przelaczanie jezyka dzialalo bez restartu.
43. Domknac error reporting launchera z anonimizacja i bez wyciekow tokenow/sekretow.
44. Zweryfikowac produkcyjny `launcher_config.json`, aby nie wskazywal na localhost ani nie mial rozjazdu URL-i.
45. Wykonac smoke test launchera na czystym Windows po artefakcie GHA.
46. Domknac `players-list.php` jako endpoint dual-world z `mode=all|classic74|modern` i polem `server` w wynikach.
47. Domknac `toplist.php` jako endpoint dual-world z merge wynikow i poprawnym sortowaniem po scaleniu.
48. Domknac `server-status.php`, aby raportowal oba serwery z trybem, online, liczba graczy i uptime.
49. Zamrozic finalny kontrakt payloadow API dla `login`, `register`, `ticket`, `context`, `sync-*`, `toplist`, `players-list`.
50. Ujednolicic format bledow we wszystkich endpointach API (`errorCode`, `errorMessage`, opcjonalne details).
51. Dodac structured logging po stronie API: endpoint, account_id, IP hash, result i timestamp bez sekretow.
52. Wdrozyc recovery flow resetu hasla przez email dla konta globalnego.
53. Rozwazyc i dopiac verification email po rejestracji, jezeli ma pozostac w aktualnym zakresie projektu.
54. Domknac brakujace tabele i przygotowanie `canary_modern` pod funkcje, ktore nadal dokumentacja raportuje jako niepelne po stronie DB.
55. Wykonac finalny test `rejestracja -> konto istnieje w obu bazach`, jako osobny test E2E po triggerach/provisioningu.
56. Naprawic `serverlist.lua` w lock-mode tak, aby nie kluczowal wpisow tylko po `host`, bo to gubi wiele serwerow na tym samym hoscie.
57. Dopiacz replay protection ticketow tak, aby nonce nie byly trzymane tylko in-memory, ale mialy spojna warstwe globalna po restarcie/proxy/multi-instance.
58. Ustalic trusted proxy policy dla IP-bindingu launch tokenow zamiast surowego `REMOTE_ADDR`.
59. Naprawic niespojny fallback `login.php` dla pustego `gameMode`, tak aby postacie nie byly mapowane wszystkie do `worldId=0`.
60. Utrzymac i uzupelnic wpisy `PASS/FAIL/BLOCKED` w dodatkowych matrycach testowych (`T-INS-*`, `T-LAU-*`, `W90-W98`) zamiast trzymac je tylko jako plan.