# Plany na przyszłość

Ten dokument zbiera plany rozwoju dla:
- serwera Canary,
- klienta otclient (TTF / i18n),
- danych świata i zasobów.

Bazuje na istniejących dokumentach:
- `../testyy/plan.md`
- `../testyy/I18N_Next_Steps.md`
- `../testyy/WszystkieSRCLOG.md`

## 1. Serwer Canary

Przykładowe kierunki (doprecyzuj według własnych priorytetów):

- utrzymanie zgodności z aktualnymi wersjami datapacków,
- porządkowanie i modularizacja skryptów Lua (np. przenoszenie logiki do modułów),
- rozbudowa monitoringu i metrics (patrz `metrics/README.md`).

## 2. Klient otclient (TTF / i18n)

- dokończenie implementacji i18n zgodnie z `../testyy/I18N_Next_Steps.md`:
  - pełne pokrycie UI tłumaczeniami,
  - konfiguracja języka z poziomu klienta,
  - testy pod różnymi systemami (Windows / Linux).
- dopracowanie systemu fontów TTF (wygładzenie, wybór fontów, rozmiary).
- ewentualne wsparcie dla dodatkowych języków i alfabetów.

## 3. Dane świata i zasoby

- uporządkowanie struktury danych klienta (pliki w `testyy/data/...`),
- dokumentacja sposobu przygotowania archiwów z danymi (jak dzielić, jak odtwarzać),
- ewentualne skrypty automatyzujące pakowanie/rozpakowywanie.

## 4. Infrastruktura i CI/CD

- dalsze usprawnianie workflow GitHub Actions (build Windows / Linux),
- ewentualne dodanie automatycznych release'ów z gotowymi binarkami (bez danych),
- monitorowanie czasu kompilacji i stabilności buildów.

## 5. Dokumentacja

- rozwijanie tego katalogu `dokumentacja/` w miarę postępów,
- okresowe aktualizowanie:
  - historii projektu,
  - listy problemów i rozwiązań,
  - listy różnic względem oryginalnych repozytoriów.

Szczegółowe TODO i priorytety nadal trzymamy w `../testyy/plan.md` – ten plik ma być podsumowaniem i mapą drogową na wyższym poziomie.
