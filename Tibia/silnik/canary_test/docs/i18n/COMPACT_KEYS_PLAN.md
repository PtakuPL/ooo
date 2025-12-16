# 🔑 Compact Keys (2–7) — Plan wdrożenia i integracji

**Data:** 2025-12-15  
**Cel:** Zmniejszyć payload serwer→klient przez zastąpienie długich kluczy semantycznych krótkimi identyfikatorami (2–7 znaków), przy zachowaniu stabilności i możliwości debugowania.

---

## 1) Założenia i definicje

- **Klucze semantyczne (source-of-truth):** obecne klucze typu `npc.rashid.greeting`, przechowywane w `i18n/en/*.json` i używane w kodzie.
- **Klucze compact (transport/klient):** krótkie ID (2–7 znaków) wysyłane w protokole i używane w słownikach klienta.
- **Mapping:** trwała relacja `semantic_key → compact_id`.

**Wymagania:**
- Compact ID ma długość **min=2, max=7**.
- Musi wyczerpać przestrzeń 2-znakową zanim zacznie generować 3-znakowe itd.
- Każdy compact ID jest unikalny i stabilny w czasie.

---

## 2) Pliki i artefakty (kanoniczne)

### 2.1 Mapping (serwer repo)
- `i18n/keymap.json` — `{ "semantic.key": "Ab" }`
- `i18n/keymap_rev.json` — `{ "Ab": "semantic.key" }` (debug/verify)
- `i18n/keymap_meta.json` — parametry generatora i licznik `next_id`

### 2.2 Słowniki klienta
- Semantyczne (obecne): `testyy/data/locales/game_i18n_{lang}.lua`
- Compact (nowe): `testyy/data/locales/game_i18n_{lang}_compact.lua`

---

## 3) Narzędzia

### 3.1 Generator mappingu
- Narzędzie: `tools/i18n_keymap.py`
- Komendy:
  - `sync` — dopisuje brakujące mapowania dla wszystkich kluczy z EN
  - `verify` — weryfikuje unikalność, zakres długości, alfabet i pokrycie

**Przykładowe użycie:**
- `python3 tools/i18n_keymap.py sync --i18n-dir i18n --min-len 2 --max-len 7`
- `python3 tools/i18n_keymap.py verify --i18n-dir i18n`

### 3.2 Eksporter klienta (JSON→Lua)
- Narzędzie: `tools/json_to_lua_locales.py`
- Nowy tryb: `--compact-keys`

**Przykładowe użycie:**
- `python3 tools/json_to_lua_locales.py --lang pl --compact-keys --i18n-dir i18n`

---

## 4) Plan wdrożenia — etapy

### Etap A — stabilizacja mappingu (repo)
**Cel:** mapping istnieje i obejmuje 100% kluczy EN.

- A1) Uruchom `i18n_keymap.py sync` (generuje/uzupełnia mapping)
- A2) Uruchom `i18n_keymap.py verify`
- A3) Dodaj do statusu workera metryki mappingu:
  - `mapped_keys`, `en_keys_total`, `next_id`, `min_len`, `max_len`, `alphabet`

**Kryterium DONE:** brak błędów verify + mapping obejmuje wszystkie EN.

### Etap B — generacja compact locales dla klienta
**Cel:** klient ma kompletne słowniki compact.

- B1) Uruchom eksport `--compact-keys` dla wybranych języków (min: `en`, `pl`).
- B2) Dodaj walidację spójności:
  - liczba wpisów w compact locale = liczba kluczy EN dla danej kategorii
  - brak duplikatów i brak pustych wartości

**Kryterium DONE:** `game_i18n_{lang}_compact.lua` istnieje i ma komplet kluczy.

### Etap C — protokół: serwer wysyła compact, kod dalej używa semantycznych
**Cel:** minimalna inwazyjność: kod generuje semantyczny klucz, dopiero na wyjściu do protokołu mapujemy go na compact.

- C1) Dodać na serwerze funkcję mapującą `semantic_key → compact_id`.
- C2) W miejscach wysyłki (LocalizedTextMessage / LocalizedCreatureSay) zamienić payload `i18nKey` na compact.
- C3) Dodać fallback (na czas migracji):
  - jeśli brak mappingu → wyślij semantyczny klucz (debug) albo EN (awaryjnie) — wybór w planie protokołu.

**Kryterium DONE:** klient dostaje compact ID i tłumaczy.

### Etap D — klient: odczyt compact słowników
**Cel:** klient tłumaczy po compact ID.

- D1) Ładowanie `game_i18n_{lang}_compact.lua`.
- D2) `tr()` szuka tłumaczenia w compact locale.
- D3) Kompatybilność: opcjonalne utrzymanie semantycznego locale dla debug/dev.

**Kryterium DONE:** runtime działa na compact ID.

### Etap E — rollout i bezpieczeństwo
- E1) Feature flag w `config.lua` (np. `i18nUseCompactKeys = true/false`).
- E2) Canary rollout: włącz na 1 środowisku/test serwerze.
- E3) Telemetria/log: zliczać fallbacki (brak mappingu/brak tłumaczenia).
- E4) Po stabilizacji: wymusić compact (brak mappingu = błąd w pipeline).

---

## 5) Statusy (dashboard)

**Cel:** `I18N_STATUS.md` ma pokazywać realny stan pracy workera + postęp compact keys.

Minimalne pola/sekcje do dodania:
- Compact keys: `mapped/en_total`, `next_id`, `min..max`, `ostatnia akcja (sync/export)`
- W tym cyklu: czy wykonano `keymap sync`, czy wykonano eksport compact locales

---

## 6) Ryzyka i decyzje

- **Stabilność kluczy:** mapping musi być append-only; nigdy nie regenerujemy od zera.
- **Debugowanie:** `keymap_rev.json` pozwala łatwo znaleźć semantyczny klucz dla compact ID.
- **Rozjazd statusów:** ujednolicić, które pliki są źródłem prawdy (patrz aktualizacja docs o statusach).

---

## 7) Kryteria akceptacji (QA)

- 100% EN keys ma mapping i jest eksportowane do locale compact.
- Serwer wysyła compact ID, klient pokazuje prawidłowe tłumaczenia.
- Brak masowych fallbacków w logach.
- `I18N_STATUS.md` pokazuje spójne liczby z `i18n/en/*.json` + mapping.
