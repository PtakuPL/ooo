# Fix: translate_limit bug + sub-batch saves + parallel_langs=1

**Data:** 2026-02-26  
**Pliki:** `i18n_worker_simple.sh`, `guardian_profile.json`, `worker_config.json`

## Problem

Worker tłumaczył 1048 kluczy w jednym ciągu (CS/npc.json) przy ustawionym `translate_limit=30`.
- Brak aktualizacji statusu przez ~16 minut
- GT zużywał dużo requestów bez przerw
- Parallel_langs=3 oznaczał 3 języki w jednym cyklu — długie cykle

## Diagnoza (root cause)

**Bug w translate_limit**: Sprawdzenie limitu w głównej pętli liczyło tylko `translated` (tłumaczenia z TM), ale `gt_pending` zbierał WSZYSTKIE klucze do GT bez żadnego limitu:
```python
# PRZED (bug):
if translate_limit > 0 and translated >= translate_limit:  # translated=0 (TM), gt_pending=1048
    break  # NIGDY nie wchodziło bo translated=0 < 30
```

Potem sekcja GT przetwarzała WSZYSTKIE 1048 kluczy z `gt_pending` bez limitu.

## Zmiany

### 1. Fix translate_limit (linia ~14769)
```python
# PO (fix):
_total_queued = translated + len(gt_pending)
if translate_limit > 0 and _total_queued >= translate_limit:
    print(f"⚠️ Osiągnięto limit {translate_limit} tłumaczeń (translated={translated}, gt_pending={len(gt_pending)})")
    break
```
Teraz limit uwzględnia zarówno TM jak i GT pending.

### 2. Sub-batch saves w GT (nowa sekcja)
Dodano mechanizm okresowego zapisu JSON podczas przetwarzania GT:
- `_SUB_BATCH_SAVE_INTERVAL = translate_limit` (domyślnie 25-30)
- `_SUB_BATCH_PAUSE_SEC = 3` — 3s pauza między sub-batchami
- `_save_lang_json_partial()` — atomowy zapis lang JSON na dysk
- `_sub_batch_checkpoint()` — wywoływany po każdym udanym tłumaczeniu GT (Cloud + Free)

Efekt: co ~25-30 tłumaczeń GT następuje:
1. Zapis JSON na dysk (postęp nie ginie)
2. Aktualizacja pliku postępu dla heartbeat
3. Pauza 3s (pozwala na GT cooldown + status update)

### 3. parallel_langs = 1
- `guardian_profile.json`: `"parallel_langs": 1`
- `worker_config.json`: `"parallel_langs": 1`

Efekt: każdy cykl obsługuje 1 język. Przy 11 językach rotacja trwa 11 cykli.

## Weryfikacja

Po restarcie workera:
```
🔄 CYKL #6 - 2026-02-26 00:19:55
🌍 AUTO TRANSLATE: pl <- quests.json (limit: 30, strict: true, GT: true)
⚠️ Osiągnięto limit 30 tłumaczeń (translated=22, gt_pending=8)
💾 Sub-batch save: 9 tłumaczeń zapisanych (total GT: 8), pauza 3s
```

- Limit działa: `translated=22 + gt_pending=8 = 30` (dokładnie limit)
- Sub-batch save: atomowy zapis po 9 tłumaczeniach GT
- Parallel=1: brak linii "🔀 Parallel", 1 język per cykl
