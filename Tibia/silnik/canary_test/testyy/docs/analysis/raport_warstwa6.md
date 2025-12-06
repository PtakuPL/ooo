# Raport — Warstwa 6 (Installer/Launcher Multi-Language Audit)

## Zakres
- Szukane artefakty: `launcher_config.json`, pliki instalatora (`*.xaml`, `.resx`), oraz moduły launchera/enter game (`/modules/client_entergame`).

## Wynik
- W drzewie `canary/` brak plików instalatora/launchera (`launcher_config.json`, `.xaml`, `.resx`).
- W `canary_test/testyy` znaleziono jedynie zasoby Android (ikony `ic_launcher*.xml/.webp`) i UI klienta (`modules/client_entergame/*.otui`, `*.lua`); brak desktopowego instalatora/launchera.

## Wniosek
- Brak materiałów do audytu instalatora/launchera w tej gałęzi. Nie można wskazać brakujących tłumaczeń ani hard-coded tekstów dla instalatora/launchera.

## Rekomendacja
1) Dostarczyć pliki instalatora/launchera (konfiguracja, pliki XAML/RESX, ewentualne JSON-y), z których korzysta build.
2) Po udostępnieniu zasobów wykonać skan: hard-coded teksty w XAML/RESX, brakujące tłumaczenia dla dostępnych języków, mapowanie na locale klienta.
