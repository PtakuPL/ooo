# Raport — Warstwa 6 (Installer/Launcher Multi-Language Audit)

## Zakres
- Szukane artefakty: `launcher_config.json`, pliki instalatora (`*.xaml`, `.resx`), oraz moduły launchera/enter game (`/modules/client_entergame`).

## Wynik
- W drzewie `canary/` nadal brak fizycznych plików desktopowego instalatora (`launcher_config.json`, `.xaml`, `.resx`).
- Przeprowadzono audyt modułów launchera (`modules/client_entergame`):
  - `entergame.otui`: tooltip z ostrzeżeniem o przechowywaniu e‑maila został objęty `tr(...)`, dzięki czemu komunikat może być tłumaczony.
  - `createAccount.otui`: wszystkie teksty interfejsu (nagłówki paneli, checkbox TOS, przyciski „Suggest Name”/„Change World”/„Start Playing”, komunikat o ReCAPTCHA, przyciski „Back/Ok/Reset”, reguły hasła itd.) zostały otagowane `tr(...)`.
  - `modules/client_locales/neededtranslations.lua`: dodano zestaw nowych kluczy, aby CI wychwytywało brakujące tłumaczenia dla powyższych stringów oraz tooltipu z konfiguracji `config.otml`.

## Wniosek
- Launcher wbudowany w klienta (ekran Enter Game + kreator konta) jest teraz gotowy na tłumaczenia, jednak nadal brakuje materiałów desktopowego instalatora – nie ma czego tłumaczyć poza kodem klienta.

## Rekomendacja
1) Zachować aktualny audyt UI launchera i uzupełniać tłumaczenia w `data/locales/*.lua` według nowych kluczy z `neededtranslations.lua`.
2) Jeśli planujemy wielojęzyczny installer poza klientem (np. WPF/Qt), należy dostarczyć źródła (`launcher_config.json`, `.xaml`, `.resx`), aby objąć je tym samym procesem i18n.
