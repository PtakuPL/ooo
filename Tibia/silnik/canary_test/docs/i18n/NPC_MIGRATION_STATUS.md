# Status Migracji NPC do i18n

**Ostatnia aktualizacja:** 2025-12-11  
**Odpowiedzialny:** Agent 2 (N-Z), Agent 1 (A-M)

## Podsumowanie

| Metryka | Wartość |
|---------|---------|
| Łącznie NPC | 1025 |
| NPC z `sendTextMessage` | 317 |
| NPC z `setMessage` | 627 |
| Zmigrowane | 29 |
| W trakcie | 0 |
| Pozostałe | ~999 |

## Podział pracy

| Zakres | Agent | Status |
|--------|-------|--------|
| A-M | Agent 1 | W TOKU |
| N-Z | Agent 2 | W TOKU |

## Pipeline Status
- **Kluczy:** 39966
- **Języki:** en, pl, es, pt, de (100%)

## Zmigrowane NPC

### Litera A (Agent 2 - początkowe testy)

| NPC | Plik | Klucze | Status | Data |
|-----|------|--------|--------|------|
| a_beautiful_girl | `npc/a_beautiful_girl.lua` | `npc.a_beautiful_girl.greet` | ✅ DONE | 2025-12-08 |
| a_bearded_woman | `npc/a_bearded_woman.lua` | `npc.a_bearded_woman.*` (38 kluczy) | ✅ DONE | 2025-12-10 |
| a_behemoth | `npc/a_behemoth.lua` | `npc.a_behemoth.greet` | ✅ DONE | 2025-12-08 |
| a_beggar | `npc/a_beggar.lua` | `npc.a_beggar.*` (10 kluczy) | ✅ DONE | 2025-12-08 |
| a_dragon_lord | `npc/a_dragon_lord.lua` | `npc.a_dragon_lord.greet` | ✅ DONE | 2025-12-12 |
| a_dead_bureaucrat (1) | `npc/a_dead_bureaucrat1.lua` | `npc.a_dead_bureaucrat.*` (11 kluczy) | ✅ DONE | 2025-12-11 |
| a_dead_bureaucrat (2) | `npc/a_dead_bureaucrat2.lua` | `npc.a_dead_bureaucrat.*` (1 klucz dialogu) | ✅ DONE | 2025-12-12 |
| a_dead_bureaucrat (3) | `npc/a_dead_bureaucrat3.lua` | `npc.a_dead_bureaucrat.*` (5 kluczy) | ✅ DONE | 2025-12-12 |
| a_dead_bureaucrat (4) | `npc/a_dead_bureaucrat4.lua` | `npc.a_dead_bureaucrat.*` (4 klucze) | ✅ DONE | 2025-12-12 |
| a_dragon_mother | `npc/a_dragon_mother.lua` | `npc.a_dragon_mother.*` (11 kluczy) | ✅ DONE | 2025-12-08 |
| a_fluffy_squirrel | `npc/a_fluffy_squirrel.lua` | `npc.a_fluffy_squirrel.*` (6 kluczy) | ✅ DONE | 2025-12-10 |
| a_grumpy_cyclops | `npc/a_grumpy_cyclops.lua` | `npc.a_grumpy_cyclops.*` (3 klucze) | ✅ DONE | 2025-12-11 |
| a_swan | `npc/a_swan.lua` | `npc.a_swan.*` (10 kluczy) | ✅ DONE | 2025-12-11 |
| a_sweaty_cyclops | `npc/a_sweaty_cyclops.lua` | `npc.a_sweaty_cyclops.*` (~40 kluczy) | ✅ DONE | 2025-12-11 |

### Litera N (Agent 2) - ZAKOŃCZONE

| NPC | Plik | Klucze | Status | Data |
|-----|------|--------|--------|------|
| nah_bob | `npc/nah_bob.lua` | `npc.nah_bob.*` (12 kluczy) | ✅ DONE | 2025-12-10 |
| naji | `npc/naji.lua` | — | ⏭️ SKIP (banker) | — |
| narsai | `npc/narsai.lua` | `npc.narsai.*` (7 kluczy) | ✅ DONE | 2025-12-11 |
| nelliem | `npc/nelliem.lua` | — | ⏭️ SKIP (shop) | — |
| nelly | `npc/nelly.lua` | `npc.nelly.*` (5 kluczy) | ✅ DONE | 2025-12-11 |
| nezil | `npc/nezil.lua` | — | ⏭️ SKIP (shop) | — |
| nicholas | `npc/nicholas.lua` | — | ⏭️ SKIP (shop) | — |
| nielson | `npc/nielson.lua` | `npc.nielson.*` (7 kluczy) | ✅ DONE | 2025-12-11 |
| nienna | `npc/nienna.lua` | — | ⏭️ SKIP (shop) | — |
| nilsor | `npc/nilsor.lua` | `npc.nilsor.*` (35 kluczy) | ✅ DONE | 2025-12-10 |
| nina | `npc/nina.lua` | `npc.nina.*` (6 kluczy) | ✅ DONE | 2025-12-10 |
| ninev | `npc/ninev.lua` | `npc.ninev.*` (43 klucze!) | ✅ DONE | 2025-12-11 |
| ninos | `npc/ninos.lua` | `npc.ninos.*` (3 klucze) | ✅ DONE | 2025-12-10 |
| nipuna | `npc/nipuna.lua` | `npc.nipuna.*` (2 klucze) | ✅ DONE | 2025-12-11 |
| nokmir | `npc/nokmir.lua` | `npc.nokmir.*` (10 kluczy) | ✅ DONE | 2025-12-10 |
| norma | `npc/norma.lua` | `npc.norma.*` (12 kluczy) | ✅ DONE | 2025-12-10 |

### Litera O (Agent 2) - W TOKU

| NPC | Plik | Klucze | Status | Data |
|-----|------|--------|--------|------|
| obi | `npc/obi.lua` | `npc.obi.*` (8 kluczy) | ✅ DONE | 2025-12-11 |
| oblivion | `npc/oblivion.lua` | `npc.oblivion.*` (15 kluczy) | ✅ DONE | 2025-12-11 |
| ocelus | `npc/ocelus.lua` | `npc.ocelus.*` (13 kluczy) | ✅ DONE | 2025-12-11 |
| odemara | `npc/odemara.lua` | — | ⏭️ SKIP (shop) | — |
| oiriz | `npc/oiriz.lua` | — | ⏭️ SKIP (shop) | — |
| old_adall | `npc/old_adall.lua` | — | ⏭️ SKIP (StdModule travel) | — |
| old_rock_boy | `npc/old_rock_boy.lua` | — | ⏭️ SKIP (brak dialogów) | — |
| oldrak | `npc/oldrak.lua` | `npc.oldrak.*` (24 klucze) | ✅ DONE | 2025-12-11 |
| oliver | `npc/oliver.lua` | — | ⏳ TODO (mały) | — |
| olrik | `npc/olrik.lua` | `npc.olrik.*` (3 klucze) | ✅ DONE | 2025-12-10 |
| omrabas | `npc/omrabas.lua` | — | ⏳ TODO (BARDZO DUŻY ~551 linii) | — |
| omur | `npc/omur.lua` | — | ⏭️ SKIP (shop) | — |
| one_eyed_joe | `npc/one_eyed_joe.lua` | `npc.one_eyed_joe.*` (20 kluczy) | ✅ DONE | 2025-12-11 |
| ongulf | `npc/ongulf.lua` | — | ⏳ TODO | — |
| oressa | `npc/oressa.lua` | — | ⏳ TODO | — |
| orockle | `npc/orockle.lua` | — | ⏳ TODO | — |
| ortheus | `npc/ortheus.lua` | — | ⏳ TODO | — |
| oswald | `npc/oswald.lua` | — | ⏳ TODO | — |

## Struktura kluczy NPC

```
npc.<nazwa_npc>.greet         - powitanie
npc.<nazwa_npc>.farewell      - pożegnanie
npc.<nazwa_npc>.busy          - gdy NPC rozmawia z kimś innym
npc.<nazwa_npc>.dialog.<key>  - odpowiedzi na słowa kluczowe
npc.<nazwa_npc>.quest.<step>  - dialogi questowe
```

## Struktura plików JSON

```
i18n/
├── en/
│   └── npc/
│       ├── a.json    # NPC A*
│       ├── b.json    # NPC B*
│       ├── ...
│       └── z.json    # NPC Z*
├── pl/
│   └── npc/
│       └── ...
└── ...
```

## Użycie helpera

```lua
-- Proste powitanie
NPC_LIB.i18n.sayLocalized(player, "npc.nazwa.greet", {player:getName()}, MESSAGE_NPC_FROM)

-- Wiele wiadomości sekwencyjnie
NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
    "npc.nazwa.dialog_1",
    "npc.nazwa.dialog_2",
}, 100)
```

## Instrukcje migracji

1. **Znajdź NPC** z listy TODO powyżej
2. **Przeczytaj plik** i zidentyfikuj wszystkie `sendTextMessage` i `setMessage`
3. **Dodaj klucze** do `i18n/en/npc.json` (lub per-litera `npc/n.json`)
4. **Przetłumacz** na PL/ES/PT/DE
5. **Zamień** wywołania na `NPC_LIB.i18n.sayLocalized()` lub `npcSayMultiple()`
6. **Uruchom pipeline** `python tools/i18n_report.py --locales pl es pt de`
7. **Zaktualizuj tabelę** powyżej

## Log zmian

### 2025-12-08
- Utworzono dokument statusu
- Zmigrowano 4 NPC z litery A (testy)
- Agent 2 bierze zakres N-Z
