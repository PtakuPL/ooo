# Audyt NPC – stan internacjonalizacji

Data: 2025-12-11 17:18 UTC  
Źródło: lokalne skanowanie `data-otservbr-global/npc/*.lua`

## Wyniki skanu
- Plików NPC: **1026**
- Pliki z `i18nKey`: **445**
- Pliki **bez** `i18nKey`: **581**
- Pliki z twardymi tekstami w `NpcHandler:say`/`StdModule.say`: **100** (do natychmiastowej migracji na klucze)

Przykłady bez `i18nKey`: `chondur.lua`, `vigintius.lua`, `herbert.lua`, `malor.lua`, `romir.lua`, `vuzrog.lua`, `grombur.lua`, `ceiron.lua`, `scott_the_scout.lua`, `neill.lua`, `arkhothep.lua`, `ashari.lua`, `the_gate_keeper.lua`, `abran_ironeye.lua`, `curos.lua`, `pyromental.lua`, `corym_worker_01.lua`, `izsh.lua`, `angelina.lua`, `hjaern.lua`, … (łącznie 581).

Przykłady z twardymi stringami w `say`: `romir.lua`, `hjaern.lua`, `gnomargery.lua`, `charos.lua`, `paulie.lua`, `dalbrect.lua`, `jeronimo.lua`, `hireling.lua`, `sven.lua`, `dove.lua`, `storkus.lua`, `frosty.lua`, `duncan.lua`, `captain_dreadnought.lua`, `cledwyn.lua`, `grizzly_adams.lua`, `battlemart.lua`, `ocelus.lua`, `sigurd.lua`, `inigo.lua`, … (łącznie 100).

## Dlaczego worker ich nie robi?
- Detekcja w workerze opiera się głównie na `StdModule.say` + `text` i `i18nKey`.  
- Wiele plików używa `NpcHandler:say`/`npcHandler:say` bez `i18nKey` – nie spełniają obecnego warunku i są pomijane.  
- Efekt: dispatcher widzi 0 „needs” mimo że w plikach są twarde stringi.

## Sugestia naprawy
- Rozszerzyć detekcję w Pythonie na `npcHandler:say` / `NpcHandler:say` (oraz ewentualnie `StdModule.say` bez `text`) z literalnymi stringami i brakiem `i18nKey`.  
- Po zmianie ponownie przeliczyć `needs_migration_npc` i cykl migracji powinien ruszyć na brakujących 581 plikach (100 z bezpośrednimi stringami + reszta bez kluczy).
