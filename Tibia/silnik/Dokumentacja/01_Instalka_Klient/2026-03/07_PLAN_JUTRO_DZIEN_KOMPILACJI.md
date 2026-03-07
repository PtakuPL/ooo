# Plan Jutra — Dzień Kompilacji Całego Systemu
**Data planu:** 2026-03-06  
**Dzień realizacji:** 2026-03-07  
**Tryb:** najpierw domknięcie gate'ów technicznych, potem pierwsza pełna kompilacja  
**Zespół:** 2 agenty (Codex + drugi agent)

## 1. Cel dnia
Do końca dnia osiągnąć stan:
1. `classic74` + `modern` + `all` działają spójnie na WWW/API/launcherze.
2. Konto globalne działa end-to-end: `launcher <-> RedDAXE <-> WWW`.
3. Po zalogowaniu w launcherze nie trzeba logować się ponownie w instalce/WWW (SSO token flow).
4. Gracz ma obowiązkowy krok utworzenia postaci per serwer (konto globalne, postacie osobne).
5. System przechodzi checklistę pre-kompilacyjną i uruchamiamy pełną kompilację GHA.

## 2. Zasady operacyjne na jutro
1. Brak lokalnych kompilacji do czasu zamknięcia gate'ów `G0-G7`.
2. Każda wykonana zmiana musi mieć wpis w dokumentacji (`checklista + dziennik`).
3. Każdy błąd logiczny dopisywany od razu do backlogu.
4. Każde zadanie kończy się testem PASS/FAIL/BLOCKED.
5. Nie pushujemy „połówek” bez smoke testu.

## 3. Harmonogram dnia (proponowany)
1. `08:00-10:00` — Blok A: Canary + DB split + mapowanie świata.
2. `10:00-12:00` — Blok B: API + konto globalne + sync tokeny.
3. `12:00-14:00` — Blok C: Launcher + installer SSO i UX.
4. `14:00-16:00` — Blok D: WWW + RedDAXE + i18n + rules + clipping.
5. `16:00-18:00` — Blok E: security + monitoring + runbook rollback.
6. `18:00-22:00` — Blok F: gate pre-kompilacja + kompilacja + walidacja artefaktów.

## 4. Podział pracy na 2 agentów
### Agent A (Codex)
1. Canary/DB/API/sync/account context.
2. Integracja launcher <-> API i flow SSO.
3. Gating pre-kompilacyjny + macierz testów E2E.

### Agent B (drugi agent)
1. WWW + RedDAXE + i18n + UX.
2. Instalka gracza + packaging + konfiguracja runtime.
3. Dokumentacja i smoke testy wizualne.

## 5. Backlog zadań na jutro (szczegółowy)
Legenda:
1. `P0` krytyczne (blokuje kompilację).
2. `P1` wysokie (powinno wejść przed release candidate).
3. `P2` średnie (może wejść po pierwszej kompilacji, ale najlepiej domknąć).

### A. Canary 7.4/Modern/All + bazy danych
1. `J-CAN-01` (`P0`): zweryfikować finalne mapowanie `worldId/gameMode` w całym stacku (`classic74=0`, `modern=1`, `all=agregat`).
2. `J-CAN-02` (`P0`): domknąć separację baz (master `canaryaac`, wtórna `canary_modern`) w konfiguracji runtime.
3. `J-CAN-03` (`P0`): wdrożyć i przetestować triggery sync `accounts` (INSERT/UPDATE/DELETE).
4. `J-CAN-04` (`P0`): wykonać initial sync brakujących kont między bazami.
5. `J-CAN-05` (`P0`): test konfliktów ID/konto/email przy sync i scenariusz rollback.
6. `J-CAN-06` (`P1`): audit, czy wszystkie endpointy i strony respektują `mode` i nie wpadają w domyślne `classic74`.
7. `J-CAN-07` (`P0`): potwierdzić, że ticket flow odrzuca mismatch postać/świat.
8. `J-CAN-08` (`P1`): test równoczesnego działania obu serwerów (status, login, ticket).
9. `J-CAN-09` (`P1`): dodać checklistę „DB split health” (połączenia, ping, prawa, lag).
10. `J-CAN-10` (`P1`): udokumentować procedurę awaryjnego odpięcia modern (degraded mode).
11. `J-CAN-11` (`P1`): sprawdzić, czy tworzenie postaci trafia do właściwej bazy zależnie od `mode`.
12. `J-CAN-12` (`P1`): walidacja, że `all` nie tworzy postaci bez wyboru serwera.
13. `J-CAN-13` (`P1`): testy list graczy i online na obu bazach osobno i razem.
14. `J-CAN-14` (`P2`): dopisać guardy anty-„silent fallback” do wrong DB.
15. `J-CAN-15` (`P2`): przygotować SQL snapshot restore dla szybkiego rollbacku.

### B. API + konta globalne + sync launcher/WWW/RedDAXE
1. `J-API-01` (`P0`): spiąć jeden kontrakt konta globalnego (`accounts`) dla launcher + WWW + RedDAXE.
2. `J-API-02` (`P0`): potwierdzić działanie rejestracji konta globalnego z launchera.
3. `J-API-03` (`P0`): potwierdzić działanie rejestracji konta globalnego z RedDAXE.
4. `J-API-04` (`P0`): flow „konto z WWW -> login w launcherze przez sync token” (no manual copy).
5. `J-API-05` (`P0`): flow „konto z launchera -> auto-login WWW -> create character”.
6. `J-API-06` (`P0`): flow „konto z RedDAXE -> dostęp do WWW i launchera”.
7. `J-API-07` (`P0`): wymusić TTL i one-time-use na tokenach sync + test replay.
8. `J-API-08` (`P1`): domknąć logi audytowe dla issue/consume tokenów.
9. `J-API-09` (`P1`): znormalizować błędy API (`code`, `message`, `details`) dla klienta UI.
10. `J-API-10` (`P1`): walidacja rejestracji social (Google/Facebook/Steam) + brak secrets -> fail-closed.
11. `J-API-11` (`P1`): dodać testy rate-limit dla OAuth i sync endpointów.
12. `J-API-12` (`P1`): endpoint `account-context` ma zwracać zawsze świat + postacie per świat.
13. `J-API-13` (`P1`): dopiąć endpointy toplist/players-list dla `all/classic74/modern`.
14. `J-API-14` (`P1`): walidacja, że `all` agreguje poprawnie i oznacza źródło.
15. `J-API-15` (`P2`): przygotować kontrakt pod wspólne topki cross-server (zabicia/monety).
16. `J-API-16` (`P2`): checklista rotacji sekretów (`TICKET_SECRET`, OAuth secrets, signature keys).

### C. Launcher (Rust/Tauri) + UX logowania
1. `J-LAU-01` (`P0`): potwierdzić natywny login launcher -> `sessionKey` działa runtime.
2. `J-LAU-02` (`P0`): potwierdzić natywną rejestrację launcher -> konto globalne.
3. `J-LAU-03` (`P0`): po zalogowaniu launcher ma zapisany kontekst konta i listę serwerów.
4. `J-LAU-04` (`P0`): przycisk „Utwórz postać Classic/Modern” otwiera WWW z auto-login tokenem.
5. `J-LAU-05` (`P0`): brak dodatkowego logowania po przejściu launcher -> WWW.
6. `J-LAU-06` (`P1`): jeśli token wygasł, launcher pokazuje czytelny fallback i retry.
7. `J-LAU-07` (`P1`): launcher blokuje „Graj”, jeśli konto nie ma postaci dla wybranego serwera.
8. `J-LAU-08` (`P1`): launcher poprawnie obsługuje tryb `all` (wybór serwera przed startem).
9. `J-LAU-09` (`P1`): wersjonowanie `launcher-version.php` vs `Cargo.toml` spójne.
10. `J-LAU-10` (`P1`): sprawdzić self-update path i podpis manifestu.
11. `J-LAU-11` (`P1`): smoke i18n launcher (PL/EN + fallback) bez brakujących kluczy.
12. `J-LAU-12` (`P2`): poprawić copy i onboarding „globalne konto + postacie per serwer”.
13. `J-LAU-13` (`P2`): dodać telemetryczne logi błędów (z anonimizacją).
14. `J-LAU-14` (`P2`): przygotować checklistę testu launchera na czystym Windows.

### D. Instalka (dev/gracz) + bootstrap + aktualizacje + SSO
1. `J-INS-01` (`P0`): potwierdzić rozdział paczki dev vs paczki gracza.
2. `J-INS-02` (`P0`): graczowa paczka nie zawiera plików dev/debug.
3. `J-INS-03` (`P0`): config paczki gracza wskazuje poprawne API/manifest URL.
4. `J-INS-04` (`P0`): instalka uruchamiana z launchera dziedziczy sesję (bez drugiego logowania).
5. `J-INS-05` (`P1`): walidacja startu klienta tylko z poprawnym launch tokenem.
6. `J-INS-06` (`P1`): test aktualizacji jednego pliku przez manifest (delta update).
7. `J-INS-07` (`P1`): test uszkodzonego pliku klienta -> auto naprawa z manifestu.
8. `J-INS-08` (`P1`): dodać checklistę anty-regresji dla startu `otclient.exe`.
9. `J-INS-09` (`P2`): ujednolicić nazewnictwo artefaktów (wersja + channel).
10. `J-INS-10` (`P2`): runbook „jak złożyć paczkę gracza po kompilacji”.
11. `J-INS-11` (`P0`): ustalić finalny layout paczki gracza (`launcher`, `launcher-cli`, `client/`, `config`, `logs/`).
12. `J-INS-12` (`P0`): wprowadzić allowlist plików do paczki gracza (blokada wrzucenia plików dev).
13. `J-INS-13` (`P0`): potwierdzić brak sekretów i kluczy prywatnych w paczce gracza.
14. `J-INS-14` (`P0`): potwierdzić brak plików źródłowych i narzędzi buildowych w paczce gracza.
15. `J-INS-15` (`P1`): przygotować podpisane checksumy paczki i plików krytycznych.
16. `J-INS-16` (`P1`): dodać walidację integralności paczki przy pierwszym starcie.
17. `J-INS-17` (`P1`): sprawdzić instalację portable (bez uprawnień admina).
18. `J-INS-18` (`P1`): test ścieżek z odstępami i znakami narodowymi.
19. `J-INS-19` (`P1`): test ścieżek długich (limit Windows path).
20. `J-INS-20` (`P1`): test odczytu/zapisu w katalogach z ograniczonymi uprawnieniami.
21. `J-INS-21` (`P1`): potwierdzić, że manifest zawiera tylko pliki wymagane przez gracza.
22. `J-INS-22` (`P1`): rozdzielić kanały aktualizacji (`stable/canary/dev`) w konfiguracji instalki.
23. `J-INS-23` (`P1`): test rollbacku klienta po nieudanym update (atomowy swap).
24. `J-INS-24` (`P1`): test przerwanego pobierania (resume/retry/backoff).
25. `J-INS-25` (`P1`): test checksum mismatch (kwarantanna pliku + re-download).
26. `J-INS-26` (`P1`): test stale manifest vs nowy launcher (komunikat i auto-fix).
27. `J-INS-27` (`P0`): handshake launcher -> instalka z przekazaniem kontekstu sesji.
28. `J-INS-28` (`P0`): instalka/klient nie pyta o login przy ważnej sesji launchera.
29. `J-INS-29` (`P0`): wymusić wybór serwera jeśli `gameMode=all` i brak aktywnej postaci.
30. `J-INS-30` (`P0`): zablokować start gry jeśli konto nie ma postaci na wybranym serwerze.
31. `J-INS-31` (`P1`): fallback flow dla wygasłej sesji (odśwież tokenu bez utraty kontekstu UI).
32. `J-INS-32` (`P1`): potwierdzić czyszczenie tokenów z pamięci po starcie klienta.
33. `J-INS-33` (`P1`): potwierdzić brak tokenów w logach jawnych.
34. `J-INS-34` (`P1`): dodać dedykowane kody błędów instalki dla supportu.
35. `J-INS-35` (`P1`): walidacja konfiguracji (`schema check`) przed uruchomieniem klienta.
36. `J-INS-36` (`P1`): blokada endpointów `http://` (wymuszenie `https://` w configu gracza).
37. `J-INS-37` (`P1`): test współpracy z AV/Defender (false positive i zachowanie plików).
38. `J-INS-38` (`P1`): `repair mode` — pełny re-verify i naprawa brakujących plików.
39. `J-INS-39` (`P2`): `safe reset` — reset cache/ustawień bez kasowania postaci i konta.
40. `J-INS-40` (`P2`): skrypt czystego uninstall (z opcją zachowania logów).
41. `J-INS-41` (`P1`): UX pierwszego uruchomienia: kroki konto globalne -> wybór serwera -> postać.
42. `J-INS-42` (`P1`): komunikaty instalatora/launchera: PL/EN spójne i czytelne.
43. `J-INS-43` (`P1`): status postępu pobierania i naprawy plików (z ETA i retry count).
44. `J-INS-44` (`P1`): ekran błędów z akcjami „Napraw”, „Ponów”, „Przejdź do support”.
45. `J-INS-45` (`P1`): linki do zasad (`all/classic74/modern`) z poziomu onboardingu.
46. `J-INS-46` (`P1`): test matrycowy Windows 10/11 dla paczki gracza.
47. `J-INS-47` (`P1`): test w środowisku bez uprawnień administratora.
48. `J-INS-48` (`P1`): test na wolnym łączu i przy timeoutach API.
49. `J-INS-49` (`P1`): test startu offline (komunikat + tryb ograniczony).
50. `J-INS-50` (`P1`): test uszkodzonej paczki wejściowej (detekcja i blokada startu).
51. `J-INS-51` (`P2`): test wielu instancji launchera i blokady lock-file.
52. `J-INS-52` (`P2`): test aktualizacji przy uruchomionym kliencie (defer + restart flow).
53. `J-INS-53` (`P2`): smoke test ścieżek niestandardowych (dyski D:/E:, foldery sieciowe).
54. `J-INS-54` (`P2`): runbook supportu „najczęstsze awarie instalki i gotowe naprawy”.
55. `J-INS-55` (`P2`): checklista release „gotowość paczki gracza do publikacji”.
56. `J-INS-56` (`P2`): checklista post-release „monitoring błędów pierwszych 24h”.
57. `J-INS-57` (`P2`): przygotować różnicę `dev package` vs `player package` w jednym dokumencie.
58. `J-INS-58` (`P2`): zamknąć matrycę PASS/FAIL dla wszystkich scenariuszy instalatora.
59. `J-INS-59` (`P2`): dopisać wymagania „co musi być gotowe przed NSIS/Inno”.
60. `J-INS-60` (`P2`): przygotować backlog „instalator pełny (NSIS/Inno) — etap po MVP”.
61. `J-INS-61` (`P0`): launcher i instalka korzystają z tego samego `account-context` (jedno źródło prawdy o serwerach/postaciach).
62. `J-INS-62` (`P0`): po powrocie z WWW (create-character) instalka odświeża kontekst bez restartu.
63. `J-INS-63` (`P0`): deep-link `Utwórz postać` przekazuje `mode` + `returnUrl` i nie gubi sesji.
64. `J-INS-64` (`P0`): blokada startu klienta przy niespójnym `mode/worldId` (fail-closed).
65. `J-INS-65` (`P0`): walidacja zgodności `launcher version` vs `manifest minLauncherVersion`.
66. `J-INS-66` (`P1`): UI instalki pokazuje jawnie aktywny serwer i postać przed startem.
67. `J-INS-67` (`P1`): instalka nie pozwala uruchomić postaci z innego serwera niż wybrany.
68. `J-INS-68` (`P1`): dodać preflight wolnego miejsca na dysku (próg + czytelny błąd).
69. `J-INS-69` (`P1`): dodać preflight uprawnień zapisu do katalogu klienta i logów.
70. `J-INS-70` (`P1`): dodać skan integralności EXE/DLL przed startem (anty-podmiana).
71. `J-INS-71` (`P1`): instalka sygnalizuje kanał (`stable/canary/dev`) i wersję w UI.
72. `J-INS-72` (`P1`): wdrożyć blokadę równoczesnego update w wielu instancjach.
73. `J-INS-73` (`P1`): test migracji ustawień z poprzedniej wersji launchera.
74. `J-INS-74` (`P1`): walidacja, że package scan wykrywa artefakty build-tools i blokuje publikację.
75. `J-INS-75` (`P1`): onboarding zawiera linki do zasad `all/classic74/modern` i FAQ konta globalnego.
76. `J-INS-76` (`P1`): przełączanie języka PL/EN bez restartu launchera/instalki.
77. `J-INS-77` (`P2`): bundle supportowy (`logs + config + diagnostics`) do jednego ZIP.
78. `J-INS-78` (`P2`): tryb cichej naprawy (`repair --silent`) dla supportu.
79. `J-INS-79` (`P2`): auto-cleanup starego lock-file po crashu.
80. `J-INS-80` (`P2`): test ścieżek instalacji na dyskach zewnętrznych i udziałach sieciowych.
81. `J-INS-81` (`P2`): release notes w launcherze po update klienta.
82. `J-INS-82` (`P2`): mapa kodów błędów instalatora -> artykuły support/KB.
83. `J-INS-83` (`P2`): checklista gotowości do publikacji wersji „player package RC”.
84. `J-INS-84` (`P2`): checklista 24h po publikacji (error budget + hotfix SLA).
85. `J-INS-85` (`P2`): backlog „instalka v2” (pełny installer GUI + uninstall wizard + repair wizard).

### E. WWW Tibia + RedDAXE (portal) + i18n/UX
1. `J-WWW-01` (`P0`): domknąć i18n w krytycznych stronach konta (`account/manage`, `create`, `createcharacter`).
2. `J-WWW-02` (`P0`): usunąć remaining hardcoded EN w flow logowania/rejestracji.
3. `J-WWW-03` (`P0`): finalnie naprawić clipping dla `online`, `highscores`, login box i menu.
4. `J-WWW-04` (`P0`): wdrożyć test DPI 100/125/150% i wpisać wyniki.
5. `J-WWW-05` (`P0`): dodać i sprawdzić 3 warianty rules (`all/classic74/modern`) z treścią.
6. `J-WWW-06` (`P1`): rozdzielić highscores i shop po serwerze na runtime (usunąć 404).
7. `J-WWW-07` (`P1`): wprowadzić persystencję wyboru serwera w sesji WWW.
8. `J-WWW-08` (`P1`): myacc: jedna tożsamość konta + osobne postacie per serwer.
9. `J-WWW-09` (`P1`): listy graczy/topki: widok `all` + filtr `classic74/modern`.
10. `J-WWW-10` (`P1`): RedDAXE: to samo konto globalne co launcher (potwierdzić E2E).
11. `J-WWW-11` (`P1`): RedDAXE: i18n pełny (PL/EN minimum) + brak mixed strings.
12. `J-WWW-12` (`P1`): RedDAXE: CTA „Pobierz launcher”, „Moje konto”, „Przejdź do WWW”.
13. `J-WWW-13` (`P2`): poprawić komunikaty UX: „konto globalne / postacie osobno”.
14. `J-WWW-14` (`P2`): dodać w FAQ sekcję: „jak działa konto na 2 serwerach”.
15. `J-WWW-15` (`P2`): dopisać listę dalszych tematów (gildie globalne, role multigame, fora) jako roadmap.
16. `J-WWW-16` (`P2`): finalny smoke wszystkich tras legacy `index.php/*` i nowych tras.

### F. Sklep, płatności, audyt i bezpieczeństwo
1. `J-SEC-01` (`P1`): checkout sklepowy zawsze niesie `gameMode/worldId`.
2. `J-SEC-02` (`P1`): callback płatności idempotentny + anti-replay.
3. `J-SEC-03` (`P1`): wpisy do audit ledger dla wszystkich transakcji.
4. `J-SEC-04` (`P1`): test duplikatu callbacku i poprawnego odrzucenia.
5. `J-SEC-05` (`P1`): monitoring błędów API i OAuth (dashboard/logrotate).
6. `J-SEC-06` (`P2`): przygotować plan rekonsyliacji płatności (worker/cron).
7. `J-SEC-07` (`P2`): sprawdzić nagłówki bezpieczeństwa WWW (CSP, cookie flags, SameSite).
8. `J-SEC-08` (`P2`): checklista backup/restore DB przed i po kompilacji.

### G. Gate pre-kompilacja (warunki startu kompilacji)
1. `J-GATE-01` (`P0`): wszystkie taski `P0` mają status PASS lub świadomy BLOCKED z obejściem.
2. `J-GATE-02` (`P0`): checklista runtime smoke zamknięta (launcher + WWW + API + DB split).
3. `J-GATE-03` (`P0`): wersje artefaktów ustalone (`launcher`, `client`, `manifest`).
4. `J-GATE-04` (`P0`): `.env` i sekrety spójne (prod/stage).
5. `J-GATE-05` (`P0`): potwierdzenie, że route 404 krytyczne zostały usunięte.
6. `J-GATE-06` (`P1`): uprawnienia cache/runtime naprawione albo udokumentowane obejście.
7. `J-GATE-07` (`P1`): dokumentacja zaktualizowana (`00`, `01`, `06`, ten plan).
8. `J-GATE-08` (`P1`): plan rollbacku po nieudanej kompilacji.
9. `J-GATE-09` (`P1`): plan hotfixu po udanej kompilacji.
10. `J-GATE-10` (`P1`): finalna decyzja „START GHA” podpisana przez oba agenty.

### H. Kompilacja i walidacja po kompilacji
1. `J-COMP-01` (`P0`): uruchomić workflow serwera Canary (Linux + Windows).
2. `J-COMP-02` (`P0`): uruchomić workflow launchera (CLI + Tauri).
3. `J-COMP-03` (`P0`): uruchomić workflow paczki gracza (installer/client package).
4. `J-COMP-04` (`P0`): zweryfikować artefakty i checksums.
5. `J-COMP-05` (`P0`): wygenerować nowy manifest i podpisać.
6. `J-COMP-06` (`P0`): test aktualizacji launcherem z poprzedniej wersji.
7. `J-COMP-07` (`P0`): test login globalny + wybór serwera + start klienta.
8. `J-COMP-08` (`P0`): test tworzenia postaci per serwer po kompilacji.
9. `J-COMP-09` (`P1`): test płatności i historii zakupów (przynajmniej sandbox).
10. `J-COMP-10` (`P1`): test i18n końcowy (PL/EN) na launcher + RedDAXE + WWW.
11. `J-COMP-11` (`P1`): zamknąć dziennik buildów (`02_DZIENNIK_BUILDOW_GHA.md`).
12. `J-COMP-12` (`P1`): spisać listę zadań „dzień po kompilacji”.

## 6. Definicja gotowości do kompilacji (Definition of Ready)
1. Brak krytycznych regresji loginu/rejestracji/sync token.
2. Brak krytycznych 404 dla tras wymaganych przez launcher i WWW.
3. Dual-serwer działa w listach, topkach i tworzeniu postaci.
4. Dokumentacja opisuje aktualny stan, known issues i obejścia.

## 7. Definicja sukcesu dnia (Definition of Done)
1. Pierwsza pełna kompilacja wykonana.
2. Launcher aktualizuje klienta i uruchamia grę.
3. Konto globalne działa na 3 frontach: launcher, RedDAXE, WWW.
4. Jeden login w launcherze wystarcza do przejścia na WWW bez ponownego logowania.
5. Gracz tworzy osobne postacie dla Classic 7.4 i Modern.

## 8. Ryzyka na jutro
1. Uprawnienia runtime cache (`Permission denied`) mogą maskować część zmian.
2. Brak sekretów OAuth może zablokować social login E2E.
3. Niespójność tras legacy vs nowe route może powodować 404.
4. Rozjazd wersji launcher/manifest może blokować auto-update.

## 9. Plan awaryjny
1. Jeśli `P0` nie zamknięte do `18:00`, nie uruchamiamy pełnej kompilacji — tylko targeted dry-run.
2. Jeśli kompilacja przejdzie, ale E2E login padnie, wracamy do poprzedniego manifestu i wersji launchera.
3. Każdy rollback ma wpis do `01_DZIENNIK_PRAC.md` i `02_DZIENNIK_BUILDOW_GHA.md`.

## 10. Linkowanie planu instalki
1. Szczegóły operacyjne instalki są prowadzone równolegle w `08_PLAN_INSTALKA_JUTRO_DETALE.md`.
2. Zadania checklisty głównej `K90-K119` mapują 1:1 najważniejsze bloki `J-INS-*` i gate’y `G-INS/PG-INS`.
3. Decyzja `START GHA` wymaga zamknięcia zarówno gate globalnych (`J-GATE-*`) jak i gate instalki (`G-INS-*`).

## 11. Linkowanie planu integracji launcher + WWW + Canary
1. Szczegółowy plan integracji jest prowadzony w `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md`.
2. Zadania checklisty `K120-K149` mapują krytyczne flow E2E launcher/API/WWW/RedDAXE/Canary.
3. Decyzja `START GHA` wymaga zamknięcia również gate integracyjnego (`G-INT-*`) obok gate globalnego i installerowego.

## 12. Polityka „bez lokalnej kompilacji” (twarda)
1. Do momentu zamknięcia wszystkich trzech grup gate'ow nie wykonujemy lokalnych kompilacji:
	- globalne: `J-GATE-*`,
	- installerowe: `G-INS-*`,
	- integracyjne: `G-INT-*`.
2. Weryfikacja kompilacji odbywa sie wyłącznie przez `push` i workflow GitHub Actions.
3. Lokalne dzialania przed zamknieciem gate'ow: kod, dokumentacja, checklisty, przygotowanie artefaktow i raportow PASS/FAIL/BLOCKED.
4. Kazde naruszenie tej polityki oznacza automatyczne `NO-GO` do czasu wpisania incydentu i planu naprawczego w `01_DZIENNIK_PRAC.md`.
5. `START GHA` jest dozwolony dopiero gdy:
	- `J-GATE-01..10` sa zamkniete,
	- `G-INS-01..07` sa zamkniete,
	- `G-INT-*` sa zamkniete,
	- istnieje udokumentowana decyzja `GO`.
