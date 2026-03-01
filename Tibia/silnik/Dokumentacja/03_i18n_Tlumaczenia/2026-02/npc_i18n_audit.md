# Audyt NPC – stan internacjonalizacji

Data: 2025-12-11 19:30 UTC (aktualizacja)  
Źródło: lokalne skanowanie `data-otservbr-global/npc/*.lua`

## Wyniki skanu
| Kategoria | Liczba |
|-----------|--------|
| Plików NPC ogółem | **1026** |
| Pliki z `i18nKey` | **445** |
| Pliki z `NPC_LIB.i18n.npcSay` | **453** |
| Pliki **bez** `i18nKey` | **581** |
| Pliki z twardymi stringami w `npcHandler:say()` | **100** |
| Z tego już zmigrowane (ma NPC_LIB) | **81** |
| **Faktycznie do migracji** | **19** |
| Pliki "skeleton" (brak say/text) | **531** |

## Szczegółowa analiza 581 plików bez i18nKey

Te pliki **nie** wymagają migracji mimo braku `i18nKey`:
- **531 "skeleton"** – pliki bez żadnych `StdModule.say` ani `npcHandler:say` – nie mają tekstów do migracji
- **50 z jakimś say** – ale z tego **244 już ma NPC_LIB.i18n.npcSay** (zmigrowane poprzez inny mechanizm)

## Pliki faktycznie wymagające migracji (19)

Pliki z `npcHandler:say("literal")` bez `NPC_LIB`:
- `alaistar.lua`, `battlemart.lua`, `bertram.lua`, `chuckles.lua`, `frans.lua`
- `frederik.lua`, `ghorza.lua`, `gnomegica.lua`, `mordecai.lua`, `nelly.lua`
- `nipuna.lua`, `rock_in_a_hard_place.lua`, `romir.lua`, `seymour.lua`, `shiriel.lua`
- `sigurd.lua`, `sundara.lua`, `tandros.lua`, `the_lootmonger.lua`

## Status detekcji w workerze

✅ **Naprawione** (2025-12-11): Detekcja rozszerzona o:
1. `StdModule.say` z `text = "..."` bez `i18nKey`
2. `npcHandler:say("literal")` bez `NPC_LIB.i18n.npcSay`
3. `NpcHandler:say("literal")` bez `NPC_LIB.i18n.npcSay`
4. `npcConfig.voices` z `text = "..."` bez `i18nKey`

Worker teraz poprawnie wykrywa **19 plików** do migracji.

## Wnioski

Wcześniejsza analiza (581 brakujących) była **błędna** – liczyła pliki bez `i18nKey`, ale nie weryfikowała czy mają cokolwiek do migracji. Większość to:
- Pliki skeleton (tylko definicja NPC, brak dialogów)
- Pliki już zmigrowane przez `NPC_LIB.i18n.npcSay` (bez użycia `i18nKey`)

## Historia zmian
- 2025-12-11 17:18 – Pierwszy audyt (błędne liczby)
- 2025-12-11 19:30 – Korekta po analizie, rozszerzenie detekcji w workerze
