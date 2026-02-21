# 2026-02-21 — Guard false-positive fix (hotspoty PL/ES items+npc)

## Kontekst
W hotspotach (`pl/es` + `items.json`/`npc.json`) dominowały odrzucenia typu:
- `mixed_language`
- `mission_token`
- `artifact_tokens`

Duża część była false-positive i sztucznie pompowała `guard_fail`.

## Wprowadzone poprawki
Plik: `i18n_worker_simple.sh`

1. `artifact_tokens`
- Usunięto karanie za samo słowo `TODO` (np. ES: `TODO` = „wszystko”).
- Nadal karane są artefakty typu `FIXME`, `TODO:...`, `TODO_...`, `????`, oraz markery `[LANG]`.

2. `mission_token`
- Reguła `npc.bozo.mission_` działa tylko, gdy token nie występuje już w EN.
- Eliminuje to przypadki, gdzie tłumaczenie poprawnie zachowuje token techniczny.

3. `mixed_language`
- Dodano filtr tokenów świata gry (proper nouns / nontranslatable terms), żeby nie karać nazw własnych.
- Dla domen name/title (`item/npc/monster/spell/...`) podniesiono próg wykrycia i dodano warunek EN function-words.

4. `partial_translation_mix`
- Wyłączono dla domen name/title.
- Analiza działa na tokenach po odfiltrowaniu world-termów.

5. Spójność audytu
- Te same zasady `artifact_tokens` (bez plain `TODO`) dodano w sekcji quality audit.

## Szybka walidacja
- `bash -n i18n_worker_simple.sh` — OK
- Estymacja na historycznych hotspotach:
  - `artifact_tokens_total = 1356`
  - `artifact_plain_TODO_would_be_ignored_now = 1016`
  - `mission_token_total = 1958`
  - `mission_token_when_en_contains_same_token = 1958`

Wniosek: patch celuje dokładnie w główne false-positive bez wyłączenia ochrony na realne artefakty.
