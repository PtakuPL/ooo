# Plan S - Sklep SMS i Operacje 2 Bazy (K53-K60)

**Data:** 2026-03-05  
**Tryb:** bez kompilacji (WWW/API/docs/test matrix)  
**Powiazanie:** `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` -> K53..K60

---

## 1. Cel

1. Jeden checkout UX dla gracza, ale kazda platnosc ma twardy kontekst serwera (`classic74`/`modern`).
2. Callbacki providerow sa idempotentne i odporne na replay.
3. Historia i ksiegowanie punktow sa audytowalne (`provider_txn_id`, `world_id`, `game_mode`).
4. Przy bledach jednego komponentu mozliwe jest odzyskanie stanu (reconciliation + runbook).

---

## 2. Zakres K53-K60

### K53 Checkout server-aware
- Wymagane pola checkout:
  - `payment_method`
  - `payment_coins`
  - `payment_world_id`
  - `game_mode`
  - `account_id` (z sesji)
- Walidacja:
  - `world_id` zgodny z `game_mode` (`0->classic74`, `1->modern`)
  - metoda aktywna w konfiguracji
  - koszyk i cena dodatnie
- Persist:
  - zapis kontekstu serwera w `canary_payments` (kolumny `world_id`/`game_mode` z migracji 007)

### K54 Callback idempotency + anti-replay
- Pipeline callbacku:
  1. Normalizacja payloadu providera do wspolnego kontraktu.
  2. Walidacja podpisu/webhook secret.
  3. Wyliczenie `event_hash`.
  4. Upsert do `payment_provider_events` (unikalnosc po `provider + provider_txn_id + event_type`).
  5. Jesli duplikat -> odpowiedz `200` bez ponownego creditu.
  6. Jesli nowy -> transakcja DB: update payment + ledger entry.
- Stan eventu:
  - `received`, `verified`, `applied`, `ignored_duplicate`, `failed`.
- Stan kodu (2026-03-05 23:21):
  - wdrozony wspolny procesor `app/Payment/CallbackProcessor.php`
  - callbacki `PayPal`, `MercadoPago`, `PagSeguro` przepiete na flow idempotentny
  - credit punktow wykonywany jednokrotnie (warunkowy update + `INSERT IGNORE` do event/ledger)
  - remaining: runtime E2E providerow + finalne hardening podpisu webhook per provider

### K55 Historia zakupow i audit
- Read model:
  - widok `all` + filtry `classic74/modern`
  - kazdy rekord ma `provider`, `provider_txn_id`, `world_id`, `game_mode`, `coins_delta`, `status`
- Zrodlo:
  - `canary_payments` (order/payment state)
  - `payment_ledger_entries` (faktyczne ksiegowanie punktow)

### K56 Reconciliation
- Job cykliczny:
  - pobiera ostatnie transakcje providera (API pull)
  - porownuje z `payment_provider_events` i `payment_ledger_entries`
  - oznacza rozjazdy do retry/manual review
- Retry policy:
  - exponential backoff
  - limit prob
  - dead-letter status po przekroczeniu progu

### K57 E2E matrix (bez kompilacji)
- Testy pozytywne:
  - checkout classic74 -> callback -> ledger credit classic74
  - checkout modern -> callback -> ledger credit modern
  - historia `all` pokazuje oba wpisy z tagiem serwera
- Testy negatywne:
  - callback bez podpisu -> reject
  - callback z blednym podpisem -> reject
  - replay tego samego `provider_txn_id` -> brak podwojnego creditu
  - callback z world mismatch -> reject + audit log
- Testy odporonosci:
  - niedostepna jedna baza -> degradacja, brak cross-creditu
  - retry callbacku po timeout -> nadal idempotentnie

### K58 Plan migracji i rollback
- Forward:
  1. rollout 007 (payment world split)
  2. rollout 009 (provider events + ledger)
  3. feature flag callback pipeline (`PAYMENT_CALLBACK_V2=true`)
  4. shadow mode (read-only logging) -> switch to write mode
- Rollback:
  - toggle feature flag off
  - freeze callback consumer
  - rollback 009 (jesli brak danych krytycznych do zachowania)
  - pozostawienie 007 dopuszczalne (kolumny neutralne)

### K59 Monitoring i alerty
- Metryki:
  - callback success rate
  - duplicate callback count
  - failed signature count
  - reconciliation mismatch count
  - callback processing latency p95
- Alerty:
  - spike `failed_signature`
  - spike `failed`/`dead_letter`
  - brak nowych eventow (provider outage)

### K60 Runbook operacyjny
- Procedury:
  - onboarding nowego providera callback
  - restart/retry callback worker
  - reczne odtworzenie creditu z audytu
  - incident: duplicate credit
  - incident: wrong world credit

---

## 3. Artefakty techniczne (stan)

1. Migracja DB przygotowana:
- `apik/v1/migrations/009_payment_provider_idempotency_rollout.sql`
- `apik/v1/migrations/009_payment_provider_idempotency_rollback.sql`
2. Tabele:
- `payment_provider_events` (idempotencja callbackow)
- `payment_ledger_entries` (audit credit/debit)
3. Kod callback pipeline:
- `app/Payment/CallbackProcessor.php`
- `app/Payment/PayPal/NotifyPayPal.php`
- `app/Payment/MercadoPago/NotifyMercadoPago.php`
- `app/Payment/PagSeguro/NotifyPagSeguro.php`
- `app/Payment/MercadoPago/ApiMercadoPago.php` (`external_reference`)

---

## 4. Definition of Done (K53-K60)

1. Checkout zawsze zapisuje `world_id` i `game_mode`.
2. Callback nie nalicza punktow drugi raz dla tego samego `provider_txn_id`.
3. Historia zakupow pokazuje poprawny serwer i status.
4. Reconciliation wykrywa i raportuje rozjazdy.
5. Monitoring ma alerty dla bledow krytycznych.
6. Runbook pozwala zamknac incydent bez zgadywania.
