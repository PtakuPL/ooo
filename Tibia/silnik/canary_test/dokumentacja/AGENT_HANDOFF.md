# Agent Communication & Handoff

Dokument wspiera wymiane informacji miedzy agentami oraz zmniejsza ryzyko problemow przy laczeniu zmian z galezia `main`.

---

## 2025-12-12 – AI Agent (Claude)

**Podsumowanie:** Rozpoczęto nową fazę projektu i18n - modyfikacja protokołu klient-serwer. Serwer będzie wysyłał klucze i18n zamiast przetłumaczonych tekstów, a klient (testyy) będzie tłumaczył lokalnie używając `tr()`.

**Co zmienilem:** 
- Zaktualizowano `testyy/docs/i18n/I18N_Next_Steps.md` - dodano sekcję o protokole klient-serwer
- Dokumentacja serwera zaktualizowana w `canary_test/docs/`:
  - `I18N_SESSION_HANDOFF.md` - zmiana architektury
  - `I18N_DEVELOPMENT_ROADMAP.md` - wersja 7.0 z nowym planem
  - `I18N_PROTOCOL_IMPLEMENTATION.md` - nowy plik z checklistą

**TODO na kolejna osobe:**
- Przeanalizować `src/client/protocolgame.cpp` - funkcja `parseTextMessage()`
- Zidentyfikować format pakietu tekstowego (opcode, typ, tekst)
- Rozszerzyć parser o opcjonalne pole `i18nKey`
- Zintegrować z `tr()` z `modules/corelib/keyboard.lua`

**Blokery / ryzyka:**
- Modyfikacja protokołu wymaga synchronizacji serwer↔klient
- Trzeba zachować kompatybilność wsteczną (stary klient bez i18n)

**Pliki krytyczne:**
- `src/client/protocolgame.cpp` - parser pakietów z serwera
- `modules/corelib/keyboard.lua` - funkcja `tr()` do tłumaczeń
- `data/locales/*.lua` - słowniki tłumaczeń (już istnieją!)

---

## Jak korzystac
- Dodawaj wpis przy kazdej sesji pracy i umieszczaj go na samej gorze dokumentu.
- Zawsze podawaj date w formacie `YYYY-MM-DD` oraz nazwe agenta albo inicjaly.
- Linkuj do plikow poprzez sciezki względne (np. `src/foo/bar.cpp:42`), aby ulatwic nawigacje.
- Jezeli dokonujesz zmian w kodzie, wymien testy/komendy, ktore uruchamiales.
- Jezeli nic nie zrobiles (np. zajmowales sie analizą), napisz to wprost – cisza informacyjna utrudnia kolejnej osobie start.

## Szablon wpisu
```
## YYYY-MM-DD – Agent XYZ

**Podsumowanie:** 1-2 zdania o stanie zadania.

**Co zmienilem:** 
- najwazniejsza rzecz 1
- najwazniejsza rzecz 2

**TODO na kolejna osobe:**
- ...

**Blokery / ryzyka:**
- ...

**Prosby / pytania:** (opcjonalnie)
- ...
```

## Checklist przy przekazywaniu
- [ ] Zaktualizowano sekcje `TODO` i `Blokery`, tak aby kolejny agent wiedzial od czego zaczac.
- [ ] Pliki krytyczne wspomniano w tekscie (sciezka + krotki opis).
- [ ] Wymieniono komendy testowe lub odnotowano, ze nie byly uruchamiane.
- [ ] Jezeli potrzebna jest decyzja uzytkownika, jasno ja opisz wraz z kontekstem.

## Workflow Git aby uniknac problemu z `main`
1. `git fetch origin`
2. Przed rozpoczeciem pracy przejdz na `main` i zaktualizuj ja:  
   `git switch main && git pull --ff-only`
3. Wroc na swoja galez: `git switch <twoja-galaz>`
4. Zrebazuj prace na aktualnym `main`: `git rebase main`
5. Po zakonczonej sesji:
   - `git status` (upewnij sie, ze widzisz tylko swoje zmiany)
   - `git add <pliki>` oraz `git commit -m "Opis"`
   - `git push origin <twoja-galaz>`
6. Jesli pojawia sie konflikty:
   - Rozwiaz je lokalnie.
   - Dodaj pliki po rozwiazaniu (`git add`).
   - Kontynuuj rebase (`git rebase --continue`) i powtorz push.

Staly rytm fetch → update `main` → rebase znacząco zmniejsza szanse, ze pliki takie jak ten dziennik nie beda chcialy sie polaczyc podczas merge requesta.
