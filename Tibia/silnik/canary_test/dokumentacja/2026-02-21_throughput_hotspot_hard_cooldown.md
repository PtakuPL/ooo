# 2026-02-21 — Throughput: hard cooldown dla toksycznych targetów

## Problem
Worker wykonywał cykle na targetach z bardzo wysokim `guard_fail` i niskim `translated`, co obniżało realny throughput (dużo cykli marnowanych na te same hotspoty).

## Zmiana
W `i18n_worker_simple.sh` dodano natychmiastowy `hard cooldown` po pojedynczym toksycznym cyklu (bez czekania na dłuższe okno statystyk):
- trigger 1: `guard_fail >= TOXIC_CYCLE_MIN_GUARD_FAIL` i `translated <= TOXIC_CYCLE_MAX_TRANSLATED`
- trigger 2: `attempts >= TOXIC_CYCLE_MIN_ATTEMPTS`, `guard_fail_rate >= TOXIC_CYCLE_MIN_GF_RATE` i `translated <= 2*TOXIC_CYCLE_MAX_TRANSLATED`
- po triggerze target trafia do `guard_fail_blacklist` na `TOXIC_CYCLE_COOLDOWN` cykli

## Nowe parametry ENV
- `TOXIC_CYCLE_COOLDOWN_ENABLED` (domyślnie `true`)
- `TOXIC_CYCLE_MIN_GUARD_FAIL` (domyślnie `180`)
- `TOXIC_CYCLE_MAX_TRANSLATED` (domyślnie `25`)
- `TOXIC_CYCLE_MIN_ATTEMPTS` (domyślnie `220`)
- `TOXIC_CYCLE_MIN_GF_RATE` (domyślnie `0.88`)
- `TOXIC_CYCLE_COOLDOWN` (domyślnie `30`)

## Telemetria
Do `translation_dispatch_state.json` dodano sekcję `toxic_cycle_cooldown`:
- `enabled`, `applied`
- `config`
- `last_block`

## Szybka walidacja
- `bash -n i18n_worker_simple.sh` — OK
- Analiza ostatnich 120 wpisów `translation_guard_report.jsonl`: wykryte 4 historyczne przypadki triggera (hotspoty: `es:items.json`, `pl:items.json`, `pl:npc.json`).
