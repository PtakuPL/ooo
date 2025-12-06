# Raport — Warstwa 1 (Language Asset Auditor)

## Zakres
- Przeszukane drzewo: `Tibia/silnik/canary/**` (kod serwera) oraz dostępne zasoby testowe w `Tibia/silnik/canary_test/testyy/data/locales`.
- Szukane pliki: `data/locales/*.lua`, `modules/**/locales/*.lua`, `data/lang/*.json`, pliki UI (`*.otui`, `*.otml`), wywołania `tr(...)` w `.cpp/.h/.lua`.

## Znalezione zasoby językowe
- W głównym drzewie `canary/` **brak** katalogów `data/locales`, `modules/**/locales`, `data/lang`, brak plików `.otui` i `.otml`.
- Zasoby testowe (klient):
   - Locale: `canary_test/testyy/data/locales/` — 53 pliki (`af`, `ar`, `az`, `bg`, `bn`, `ca`, `cs`, `da`, `de`, `el`, `en`, `es`, `et`, `eu`, `fa`, `fil`, `fi`, `fr`, `gl`, `he`, `hi`, `hr`, `hu`, `hy`, `id`, `is`, `it`, `ja`, `ka`, `kk`, `ko`, `lt`, `lv`, `mk`, `ms`, `nl`, `no`, `pl`, `pt`, `ro`, `ru`, `sk`, `sl`, `sq`, `sr`, `sv`, `sw`, `th`, `tr`, `uk`, `uz`, `vi`, `zh`).
   - UI (otui): ~120 plików w `canary_test/testyy/modules/**` + ~25 styli w `canary_test/testyy/data/styles/*.otui` (pełen UI klienta). Brak odpowiedników w głównym drzewie serwera.
   - Konfiguracja locale: `canary_test/testyy/data/i18n/locales.otml` — zawiera mapowanie tagów BCP47 + script + dir (LTR/RTL). RTL zdefiniowane dla `ar-*`, `he-IL` (Hebr), `fa-IR` (Arab).
- Format plików lokalizacji: `locale = { name = "<lang>", translation = { ["English key"] = "<tłumaczenie>" } }`. Plik `en.lua` ma pustą mapę (baza kluczy), `pl.lua` ~1000 wpisów.

## Użycie systemu tłumaczeń w kodzie / UI
- W kodzie `canary/` (serwer) **0** wywołań `tr(...)` w `.cpp/.h/.lua`; serwer nie korzysta z systemu lokalizacji.
- Brak plików UI (`.otui`/`.otml`) w drzewie serwera.
- W kliencie testowym (`canary_test/testyy`): setki wywołań `tr(...)` w `.otui` i `.lua` (np. market, cyclopedia, hotkeys, entergame, options). System tłumaczeń działa tylko tam.
- Hard-coded teksty znalezione w UI testowym (brak `tr()`, wymagają lokalizacji lub potwierdzenia, że to placeholdery/dane dynamiczne):
   - `modules/client_entergame/entergame.otui`: `!specialtooltip: 'Be aware that your email address will be stored on your configuration file "config.otml" if you activate this option.'`
   - `modules/game_shop/changename.otui`: `Enter New Character Name`, `Cancel`, `Ok`, `Please enter the new name for your character:`.
   - `modules/game_shop/gift.otui`: `Enter player name`, `Confirm`, `Cancel`.
   - `modules/game_shop/game_shop.otui`: `Store`, `Close`, `History`.
   - `modules/client_options/styles/graphics/graphics.otui`: `Antialiasing Mode:`, `Full Screen Mode`, `Don't stretch/shrink Game Window`, tooltip `Ctrl+Shift+F`.
   - `modules/client_options/styles/graphics/effects.otui`: `Floor View Mode:`, `Draw Floating Effects`.
   - `modules/client_options/styles/interface/interface.otui`: `Crosshair:`, `Colourise Loot Value: `.
   - `modules/game_cyclopedia/cyclopedia_widgets.otui`: `+5%`, `Equipment loot bonus: 118%`, `0` (liczby w nawiasach bez `tr()` – do decyzji, czy to dane, czy etykiety).
   - `modules/game_cyclopedia/tab/character/character.otui`: `100`, `0/329`, `Regular`, `0/0`, `Secret`, `Sort` (podobnie: wartości/liczniki, brak `tr()`).
   - `modules/game_cyclopedia/tab/bestiary/bestiary.otui`: `?` (dwukrotnie) – brak `tr()`.
   - `modules/game_cyclopedia/tab/boss_slots/boss_slots.otui`: tooltip loot bonusu bez `tr()`.
   - `modules/game_cyclopedia/tab/charms/charms.otui`: tooltip o „Charm Expansion” bez `tr()`.
   - `modules/game_imbuing/imbuing.otui`: tooltip „Bribe the fates! Click here to raise your chance to 100%. For guaranteed success use gold.” bez `tr()`.
   - `modules/game_inventory/inventory.otui`: liczby `100000`, `10000` (kilka miejsc) – placeholdery bez `tr()`.
   - `modules/game_healthinfo/healthinfo.otui`: `155`, `60` – placeholdery bez `tr()`.
   - `modules/client_bottommenu/calendar.otui`: data „2023-11-23, 11:23 CET” bez `tr()`.
   - `data/styles/30-statsbar.otui`: `9999999999/9999999999`, `99999` (kilka miejsc) – placeholdery bez `tr()`.
   - (z wcześniejszego próbkowania) `modules/game_cyclopedia/cyclopedia_widgets.otui`: `('0')` w kilku miejscach; należy zweryfikować, czy to dane runtime czy etykiety do lokalizacji.
- W kodzie C++ (serwer) komunikaty są budowane ad-hoc (`std::string` / `fmt::format`) i nie mają warstwy tłumaczeń.

## Luki / brakujące elementy
- Brak zintegrowanego systemu lokalizacji w drzewie `canary/` (brak plików locale, hooków `tr()`, plików UI).
- Locale/otui istnieją tylko w `canary_test/testyy`; serwer nie referuje tych zasobów.
- Brak macierzy klucz × język dla serwera → nie można policzyć brakujących/nieużytych kluczy dla backendu.
- RTL/Script info istnieje w `data/i18n/locales.otml`, ale bez wykorzystania w serwerze (brak propagacji do klientów/komunikatów).

## Rekomendacje (kolejne kroki)
1) Ustalić, czy serwer powinien korzystać z tłumaczeń po stronie backendu. Jeśli tak, potrzebne:
   - dodanie plików locale do `canary/data` (lub innej ścieżki runtime),
   - wprowadzenie funkcji `tr()` lub analogicznego mechanizmu w warstwie komunikatów do klienta,
   - zmapowanie istniejących plików `canary_test/testyy/data/locales` jako źródła kluczy/bazę tłumaczeń.
2) Jeśli lokalizacje mają być tylko w kliencie, należy dostarczyć zasoby UI (`.otui/.otml`) do audytu hard-coded tekstów i upewnić się, że klient korzysta z przekazanych locale.
3) Po dostarczeniu realnych plików locale dla serwera można uruchomić porównanie kluczy (braki/nieużyte) i oznaczyć stringi hard-coded.
