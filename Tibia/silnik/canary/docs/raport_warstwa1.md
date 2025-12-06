# Raport — Warstwa 1 (Language Asset Auditor)

## Zakres
- Przeszukane drzewo: `Tibia/silnik/canary/**` (kod serwera) oraz dostępne zasoby testowe w `Tibia/silnik/canary_test/testyy/data/locales`.
- Szukane pliki: `data/locales/*.lua`, `modules/**/locales/*.lua`, `data/lang/*.json`, pliki UI (`*.otui`, `*.otml`), wywołania `tr(...)` w `.cpp/.h/.lua`.

- ## Znalezione zasoby językowe
- W głównym drzewie `canary/` **brak** katalogów `data/locales`, `modules/**/locales`, `data/lang`, brak plików `.otui` i `.otml`.
- Zasoby testowe:
   - Locale: `canary_test/testyy/data/locales/` (53 pliki): `af`, `ar`, `az`, `bg`, `bn`, `ca`, `cs`, `da`, `de`, `el`, `en`, `es`, `et`, `eu`, `fa`, `fil`, `fi`, `fr`, `gl`, `he`, `hi`, `hr`, `hu`, `hy`, `id`, `is`, `it`, `ja`, `ka`, `kk`, `ko`, `lt`, `lv`, `mk`, `ms`, `nl`, `no`, `pl`, `pt`, `ro`, `ru`, `sk`, `sl`, `sq`, `sr`, `sv`, `sw`, `th`, `tr`, `uk`, `uz`, `vi`, `zh`.
   - UI (otui): `canary_test/testyy/modules/client_entergame/*.otui` (+ pliki `.lua`); brak ich odpowiedników w głównym drzewie serwera.
- Format plików lokalizacji: struktura `locale = { name = "<lang>", ... , translation = { ["English key"] = "<tłumaczenie>" } }` (przykład: `pl.lua` ma ~1000 wpisów). Plik `en.lua` ma pustą mapę tłumaczeń.

## Użycie systemu tłumaczeń w kodzie
- W kodzie `canary/` nie znaleziono żadnych wywołań `tr(...)` (`rg "\\btr\\s*\\("` → brak trafień w `.cpp/.h/.lua`).
- Brak plików UI (`.otui`/`.otml`) → brak miejsc, gdzie można by umieszczać `text="..."` do tłumaczeń.
- W kodzie C++ dominują bezpośrednie stringi/`std::stringstream` bez mechanizmu lokalizacji.

## Luki / brakujące elementy
- Brak zintegrowanego systemu lokalizacji w drzewie `canary/` (ani plików locale, ani hooków `tr()` w kodzie, ani zasobów UI). 
- Istniejące locale w `canary_test/testyy` wyglądają na dane klienta testowego i nie są referencjonowane z kodu serwera.
- Brak baz do porównania kluczy (nie ma macierzy klucz × język w głównym kodzie), co uniemożliwia wykrycie „kluczy brakujących per język” oraz „kluczy nieużywanych” w kontekście serwera.

## Rekomendacje (kolejne kroki)
1) Ustalić, czy serwer powinien korzystać z tłumaczeń po stronie backendu. Jeśli tak, potrzebne:
   - dodanie plików locale do `canary/data` (lub innej ścieżki runtime),
   - wprowadzenie funkcji `tr()` lub analogicznego mechanizmu w warstwie komunikatów do klienta,
   - zmapowanie istniejących plików `canary_test/testyy/data/locales` jako źródła kluczy/bazę tłumaczeń.
2) Jeśli lokalizacje mają być tylko w kliencie, należy dostarczyć zasoby UI (`.otui/.otml`) do audytu hard-coded tekstów i upewnić się, że klient korzysta z przekazanych locale.
3) Po dostarczeniu realnych plików locale dla serwera można uruchomić porównanie kluczy (braki/nieużyte) i oznaczyć stringi hard-coded.
