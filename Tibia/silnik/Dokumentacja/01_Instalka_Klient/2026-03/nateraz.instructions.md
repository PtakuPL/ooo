A więc ogólnie dązymy do tego aby Nasz Serwer Canary miał możliwość posiadania 2 serwerów. 1 serwer np. 14.20+ a drugi 7.4 z wieloma ograniczeniami w serwerze jak i instalce np. blokada hotkay. w instalce w łatwy sposób będzie można przełączać się między serwerami itd oraz pod 7.4 bedą blokady hotkay na runy itd.
Aktualnie prace trwają nad wprowadzenie wielu liter świada do instalki gry, lecz mamy problem z kompilacją używając github actions.
Teraz jak sprawdzasz jakiś plik i go edytujesz to otwieraj go abyś miał go na widoku w całości, aby uninąć błędów z wcięciami czy ucięciami linii.
Pamiętaj aby na repo github wrzucać wszystko do głównej gałęzi master z ooo 
Jeśli uda nam się kompilacja instalki na windows to zadanie aktualne jest skończone. 
Serwercanary bedzię miał po prostu blokady różnych systemów/funkcji pod serwer Udawany 7.4 .
Pamiętaj aby zawsze starać się po zakoczonej pracy dopisywać co zrobiłeś jakie problemy miałeś do folderu na wsl Dokumentacja i w nim są pliki .md , pliki .md to głownie opisy prac , planów rozwiązań , i dokonanych rzeczy. 

WAŻNE — KOMPILACJA: NIGDY nie instaluj Rust toolchain, Node.js ani innych narzędzi budowania lokalnie na WSL. Wszystko kompilujemy wyłącznie na GitHub Actions (CI/CD). Lokalnie tylko piszemy kod i tworzymy pliki — weryfikacja kompilacji odbywa się przez push + GHA workflow. Dotyczy to: launchera Rust+Tauri, klienta OTClient, serwera Canary i wszelkich innych artefaktów.
Wszystkie kompilacje wykonujemy na github actions
Aktualny plan bezpieczeństwa+launcher+serwer+api+instalka z trybem modern/7.4 robimy na canary_test lokalnie oraz na branch ticket-gate!!!!!!!!