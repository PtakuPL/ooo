# Diagnostyka starego konta RedDAXE / launcher

Data: 2026-03-09  
Zakres: tylko ustalenie przyczyny problemu ze starym kontem, bez zmian w kodzie

## 1. Objaw

Stare konto:

- email: `ratetate807@gmail.com`

Nowe konto kontrolne:

- email: `cardriverkt@gmail.com`

Oba byly testowane tym samym haslem wskazanym przez wlasciciela.

Wynik:

- stare konto nie loguje sie przez `RedDAXE` / `apik/v1/login.php`
- nowe konto loguje sie poprawnie tym samym haslem

## 2. Testy wykonane

### Test 1. Bezposredni login do API

Stare konto:

```json
{"errorCode":3,"errorMessage":"Email or password is not correct.","lchCode":"LCH_WRONG_CREDENTIALS"}
```

Nowe konto:

- zwraca poprawna sesje `session.sessionkey`
- logowanie przechodzi

Wniosek:

- transport `RedDAXE -> apik/v1/login.php` dziala
- problem nie jest ogolna awaria logowania WWW
- problem dotyczy konkretnego rekordu starego konta

### Test 2. Porownanie rekordu starego i nowego konta w `GLOBAL_DB.accounts`

Stare konto `ratetate807@gmail.com`:

- `id=1021`
- `name=ptaku123`
- `password=7288edd0fc3ffcbe93a0cf06e3568e28521687bc`
- `engine_password_sha1=b374cb0ba1094cc7f672a24d63f39b59f47e6de2`

Nowe konto `cardriverkt@gmail.com`:

- `id=1022`
- `name=loko`
- `password=b374cb0ba1094cc7f672a24d63f39b59f47e6de2`
- `engine_password_sha1=b374cb0ba1094cc7f672a24d63f39b59f47e6de2`

### Test 3. Audit niespojnosci hasel

Zapytanie kontrolne:

- liczba kont, gdzie `password != engine_password_sha1`: `1`

Jedynym wykrytym rekordem z takim problemem jest:

- `id=1021`
- `name=ptaku123`
- `email=ratetate807@gmail.com`

## 3. Root cause

To konto nie wyglada na zablokowane.

Problem polega na tym, ze rekord starego konta ma rozjechane dwie kolumny hasla:

- kolumna `password`
- kolumna `engine_password_sha1`

Nowe konto ma obie kolumny zgodne.

Stare konto ma je rozne.

W praktyce oznacza to:

- haslo zapisane jako aktywne dla logowania WWW/API siedzi w `password`
- stare konto ma w tej kolumnie inny hash niz ten oczekiwany przy aktualnym hasle
- `engine_password_sha1` na starym koncie jest zgodne z haslem testowym, ale sam login korzysta z `password`

## 4. Wniosek operacyjny

To nie jest:

- globalna awaria `RedDAXE`
- problem TLS / hosta
- problem sesji WWW
- problem launchera jako takiego

To jest izolowany problem danych jednego starego konta.

Najbardziej prawdopodobny scenariusz:

- wczesniejszy etap budowy systemu kont globalnych / migracji zostawil stare konto w stanie, gdzie:
  - jedna kolumna hasla zostala zaktualizowana,
  - druga nie zostala zsynchronizowana

## 5. Co trzeba zrobic dalej

Zadanie diagnostyczno-naprawcze dla kolejnego agenta:

1. Ustalic, ktory historyczny flow mogl rozjechac `password` i `engine_password_sha1` dla starych kont:
   - stary register flow
   - stary reset hasla
   - stary change-password
   - migracja / sync kont przy poczatkach systemu

2. Potwierdzic kontrakt:
   - ktora kolumna jest oficjalnym zrodlem prawdy dla logowania WWW/API
   - czy druga kolumna ma byc tylko kompatybilnosciowa dla engine

3. Przygotowac bezpieczna naprawe:
   - najpierw one-off repair dla tego jednego konta testowego
   - potem ewentualny audit / migration repair dla wszystkich kont z warunkiem:
     - `password != engine_password_sha1`

4. Dodac test / audit stale pilnujacy, ze nowe flow rejestracji i zmiany hasla nie tworza juz takich rozjazdow.

## 6. Stan po tej diagnozie

- nie wykonano zadnych zmian w kodzie
- nie wykonano zadnych zmian w danych
- zapisano tylko ustalenia diagnostyczne
