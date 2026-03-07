# Audyt Dokumentacji i Brakow
**Data:** 2026-03-06  
**Zakres:** analiza aktywnej dokumentacji pod katem brakow, rozjazdow, luk informacyjnych i blockerow przed jutrzejsza kompilacja  
**Tryb:** bez kompilacji, tylko analiza i uzupelnienie `.md`

## 1. Wniosek glowny

Dokumentacja jest obszerna i zawiera wiekszosc potrzebnego zakresu technicznego, ale miala 4 realne braki organizacyjne:
1. brak jednej, jawnej mapy `source of truth`,
2. brak jednego audytu dokumentacyjnego z lista rozjazdow i blockerow,
3. rozproszenie blockerow jutra miedzy wiele plikow,
4. co najmniej jeden uszkodzony fragment dokumentu (`03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`).

Te braki zostaly czesciowo zamkniete w tej aktualizacji dokumentacji.

## 2. Co bylo brakujace

### B1. Brak mapy dokumentow aktywnych vs historycznych
Objaw:
- nie bylo jasno zapisane, ktore pliki sa operacyjne na jutro,
- duze pliki architektoniczne mieszaly sie z planami dziennymi i starymi snapshotami.

Ryzyko:
- latwo pracowac na nieaktualnym planie,
- trudniej ocenic, gdzie dopisywac status i blocker.

Status:
- **uzupelnione teraz** przez sekcje `0.1 Aktualna mapa dokumentacji` w `plan_zabezpieczenia_klienta_i_serwera.md`.

### B2. Brak jednego audytu brakow dokumentacyjnych
Objaw:
- braki runtime, secrets, deploy drift, i18n, dual-db i integracja byly opisane, ale rozrzucone.

Ryzyko:
- jutro mozna uznac system za "gotowy do kompilacji", mimo ze czesc blockerow jest tylko w jednym pobocznym pliku.

Status:
- **uzupelnione teraz** przez ten dokument.

### B3. Brak jednej listy realnych blockerow przed kompilacja
Objaw:
- blockerami sa nie tylko buildy, ale tez runtime smoke, sekrety, cache permissions, dual-db i SSO,
- to nie bylo zebrane w jednym miejscu.

Ryzyko:
- falszywe `go/no-go`.

Status:
- **uzupelnione teraz** w sekcji 4.

### B4. Brak matrixu "repo vs runtime vs E2E"
Objaw:
- wiele zadan ma status typu `kod gotowy`, `runtime pending`, `lokalny smoke PASS`, ale bez jednego wspolnego formatu.

Ryzyko:
- nie wiadomo, czy cos jest:
  - tylko napisane w docs,
  - gotowe w repo,
  - wdrozone na runtime,
  - potwierdzone end-to-end.

Status:
- **nadal otwarte** — czesciowo widoczne w `00_START_PRACY_CHECKLISTA.md`, ale brak osobnej, znormalizowanej tabeli stanu.

### B5. Brak centralnego opisu blockerow operacyjnych
Objaw:
- sekrety OAuth, brak finalnego smoke `/reddaxe`, 404 na `community/highscores` / `shop/payment`, cache `Permission denied`, dual PDO i triggery sync sa opisane osobno.

Ryzyko:
- trudniej ocenic, co naprawiac rano jako pierwsze.

Status:
- **uzupelnione czesciowo teraz** przez sekcje 4; nadal wymaga codziennej aktualizacji w `00` i `01`.

### B6. Uszkodzony fragment dokumentu
Objaw:
- w `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` na koncu wisialy urwane punkty `4.` i `5.`.

Ryzyko:
- dokument wygladal na niedomkniety i wprowadzal szum.

Status:
- **naprawione teraz** — punkty przeniesione do sekcji `12.5 Warunki uruchomienia (BLOCKED)`.

## 3. Co uzupelniono teraz

1. Zaktualizowano `plan_zabezpieczenia_klienta_i_serwera.md`:
- dopisano mape dokumentacji i zasady `source of truth`,
- odswiezono naglowek statusu i timestamp aktualizacji.

2. Naprawiono `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`:
- przywrocono spojna sekcje `12.5`,
- usunieto urwany ogon dokumentu.

3. Dodano ten audyt:
- jeden plik z opisem brakow, rozjazdow i blockerow.

## 4. Realne blokery przed jutrzejsza kompilacja

To jest lista blockerow, ktore wynikaja z aktualnej dokumentacji, a nie z przypuszczen.

| Bloker | Status | Gdzie sledzony |
|---|---|---|
| Dual-db sync kont (`K61`, `K81`, `K140`) | ⬜ TODO | `00`, `03`, `07`, `09` |
| Finalny runtime E2E konta globalnego launcher <-> WWW <-> RedDAXE | ⬜ TODO | `00`, `07`, `09` |
| Natywny login/rejestracja launchera runtime E2E | 🔄 kod gotowy, runtime pending | `00`, `03`, `09` |
| Instalka: gate `G-INS` i finalny `go/no-go` | ⬜ TODO | `08`, `00` |
| Integracja: gate `G-INT` i matryca `T-INT-01..12` | ⬜ TODO | `09`, `00` |
| Legacy WWW i18n/clipping + trasy krytyczne | 🔄 PARTIAL | `06`, `00`, `07`, `09` |
| `community/highscores` i `shop/payment` runtime 404 | ⬜ TODO | `00`, `03`, `06`, `09` |
| RedDAXE `/reddaxe` runtime smoke finalny | 🔄 PARTIAL | `04`, `00`, `09` |
| OAuth/social secrets i callback URLs | ⬜ TODO / pending runtime | `03`, `00`, `plan_zabezpieczenia...` |
| Runtime cache / `Permission denied` dla purge | 🔄 PARTIAL / workaround | `06`, `00` |
| Finalna decyzja `START GHA` po gate globalnym + installerowym + integracyjnym | ⬜ TODO | `07`, `08`, `09`, `00` |

## 5. Dokumenty aktywne na jutro

### Operacyjne
1. `00_START_PRACY_CHECKLISTA.md`
2. `01_DZIENNIK_PRAC.md`
3. `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md`
4. `08_PLAN_INSTALKA_JUTRO_DETALE.md`
5. `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md`

### Tematyczne
1. `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`
2. `04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md`
3. `05_PLAN_SKLEP_SMS_2_BAZY.md`
4. `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md`
5. `plan_zabezpieczenia_klienta_i_serwera.md`

### Historyczne / referencyjne
1. `2026-03-05_PLAN_PRZED_KOMPILACJA.md`
2. `2026-03-03_launcher_sprint*.md`
3. `launcher+rust*.md`

## 6. Braki nadal otwarte w samej dokumentacji

1. Brakuje jednej tabeli stanu `repo / runtime / E2E / owner` dla wszystkich krytycznych zadan.
2. Brakuje jednego zbiorczego raportu `go/no-go` po faktycznym przejsciu wszystkich gate'ow.
3. Dokumenty referencyjne launchera nie sa oznaczone, ktore fragmenty sa juz wdrozone, a ktore zostaly tylko jako spec.
4. `plan_zabezpieczenia_klienta_i_serwera.md` jest nadal ogromnym dokumentem laczacym architekture historyczna i aktualny backlog; do dalszego etapu warto go podzielic.

## 7. Zasady utrzymania dokumentacji od teraz

1. Status zadania aktualizujemy tylko w `00_START_PRACY_CHECKLISTA.md`.
2. Przebieg pracy i decyzje wpisujemy tylko do `01_DZIENNIK_PRAC.md`.
3. Plan jutra utrzymujemy tylko w `07`, `08`, `09`.
4. Bloker wykryty podczas runtime testu musi trafic tego samego dnia do:
- `00_START_PRACY_CHECKLISTA.md`,
- `01_DZIENNIK_PRAC.md`,
- dokumentu tematycznego (`03/04/05/06/08/09`) jesli dotyczy konkretnego obszaru.

## 8. Ocena koncowa po audycie

Dokumentacja po tej aktualizacji jest wyraznie bardziej uporzadkowana, ale **nie jest jeszcze "zamknieta"**. Najwieksze otwarte braki nie dotycza juz liczby dokumentow, tylko braku domknietych testow runtime/E2E i braku finalnej tabeli `repo vs runtime vs E2E`.
