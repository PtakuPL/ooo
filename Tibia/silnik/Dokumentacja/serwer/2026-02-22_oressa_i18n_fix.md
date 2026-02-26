# Fix NPC Oressa: i18n — P11 + P3 + P10
**Data**: 2026-02-22  
**Status**: NAPRAWIONE + HOTFIX 2026-02-23 — wymaga testów  
**Pliki zmienione**:
- `data/libs/i18n_wrappers.lua` — dodano `npcSayMultiple`
- `data-otservbr-global/npc/oressa.lua` — poprawiono klucze i18n
- `i18n/en/npc.json` — dodano brakujące klucze, naprawiono `\z`
- `i18n/pl/npc.json` — dodano brakujące klucze, poprawiono tłumaczenia

---

## Aktualizacja 2026-02-23 (hotfix gameplay)

W `oressa.lua` dopięto dodatkową stabilizację krytycznych ścieżek dialogowych:

- Zamiana części użyć `say_1..say_17` na klucze semantyczne:
  - `knight_info_1..3` + `knight_confirm_1`
  - `paladin_info_1..4` + `paladin_confirm_1`
  - `druid_info_1..3` + `druid_confirm_1`
  - `sorcerer_info_1..3` + `sorcerer_confirm_1`
- Poprawa warunków logicznych `or/and`:
  - `(choosing OR choose) AND topic==0`
  - `(bow OR spear) AND topic==3`

Cel hotfixu: ograniczyć ryzyko błędnych przejść dialogowych i uniezależnić krytyczne gałęzie od niestabilnych mapowań `say_*`.

---

## Znalezione problemy (ROOT CAUSE)

### 1. `NPC_LIB.i18n.npcSayMultiple` — funkcja nie istniała
- W `i18n_wrappers.lua` była zdefiniowana `npcSayTable`
- oressa.lua wywoływała `npcSayMultiple` → **nil function error**
- **KAŻDY** wielowiadomościowy dialog NPC (vocation, knight, paladin, druid, sorcerer, potwierdzenie, odmowa) crashował
- Dodatkowo `npcSayTable` nie miała wsparcia opóźnień — wysyłała wszystkie wiadomości naraz

### 2. Złe mapowanie kluczy i18n w oressa.lua
Auto-migrator niepoprawnie przypisał klucze `say_*`:

| Kod oressa.lua | Użyty klucz | Faktyczna zawartość klucza | Oryginalna wiadomość |
|---|---|---|---|
| healing healed | `say_1` | KNIGHT text | "You are hurt, my child..." |
| healing not needed | `say_2` | KNIGHT text | "You do not need any healing..." |
| help not needed | `say_3` | KNIGHT text | "You do not need any healing..." |
| help healed | `say_4` | KNIGHT text | "You are hurt, my child..." |
| distance prompt | `say_5` | PALADIN text | "Tell me: Do you prefer {bow}..." |
| decided prompt | `say_6` | PALADIN info | "So tell me, which {vocation}..." |

### 3. Potwierdzenie wyboru (say_18+19) — utrata nazwy profesji
- Oryginał: `"SO BE IT. RISE, NOBLE " .. player:getVocation():getName():upper() .. "! ..."`
- i18n: `say_18` = "SO BE IT...NOBLE" + `say_19` = "! ..." — **nazwa profesji zgubiona**

### 4. Odmowa wyboru (say_22+23) — utrata listy alternatyw
- Oryginał: `"...about the " .. vocationMessage[topic] .. " vocation, tell me."`
- i18n: `say_22` + `say_23` — **dynamiczna lista profesji zgubiona**

### 5. `\z` w tłumaczeniach JSON
- Lua escape `\z` (whitespace eater) przeniósł się dosłownie do JSON
- Dotyczyło: `greet_msg_1`, `greet_msg_2`, `voice_1`, `stdmod_11`, `stdmod_12`

### 6. Błędne polskie tłumaczenia
- `farewell_msg_1`: "Robić widzenia" → powinno "Do widzenia"
- `stdmod_8`: "[EN] I am Oressa..." → niprzetłumaczone z prefiksem EN
- `stdmod_17`: "I masz heard z to, Tak." → nonsens, powinno "Słyszałam o tym, tak."

---

## Zastosowane poprawki

### A. `data/libs/i18n_wrappers.lua` — nowa funkcja `npcSayMultiple`
```lua
function NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, keys, delay, args)
    -- Tłumaczy KAŻDY klucz server-side
    -- Buduje tabelę przetłumaczonych tekstów
    -- Przekazuje do npcHandler:say(translated, npc, player, delay)
    -- → doNPCTalkALot() → npc:sayWithDelay() z prawidłowymi opóźnieniami
end
```

### B. `oressa.lua` — naprawione mapowania kluczy
| Stary klucz | Nowy klucz | Opis |
|---|---|---|
| `say_1` (healing) | `healing_healed` | "Jesteś ranny, uleczę twoje rany" |
| `say_2`, `say_3` (healing) | `healing_not_needed` | "Nie potrzebujesz leczenia" |
| `say_4` (help) | `healing_healed` | Jak wyżej |
| `say_5` (distance) | `distance_prompt` | "Czy wolisz bow/spear czy magic?" |
| `say_6` (decided) | `decided_prompt` | "Jaką vocation chcesz wybrać?" |

### C. `oressa.lua` — naprawione potwierdzenie/odmowa
```lua
-- Potwierdzenie: say_18 z {0} = nazwa profesji
local vocName = player:getVocation():getName():upper()
NPC_LIB.i18n.npcSayMultiple(..., {"say_18", "say_20", "say_21"}, 10, {vocName})

-- Odmowa: say_22 z {0} = lista alternatywnych profesji  
local altVocations = vocationMessage[topic]
NPC_LIB.i18n.npcSay(..., "say_22", {altVocations})
```

### D. Tłumaczenia EN + PL — nowe klucze + naprawy
**Dodane klucze** (EN + PL):
- `npc.oressa.healing_healed`
- `npc.oressa.healing_not_needed`
- `npc.oressa.distance_prompt`
- `npc.oressa.decided_prompt`

**Naprawione klucze** (EN + PL):
- `say_18`: dodano `{0}` placeholder dla nazwy profesji
- `say_22`: dodano `{0}` placeholder dla listy profesji
- `greet_msg_1`, `greet_msg_2`: usunięto `\z`
- `voice_1`, `stdmod_11`, `stdmod_12`: usunięto `\z`
- `farewell_msg_1` (PL): "Do widzenia, dziecko."
- `stdmod_8` (PL): "Jestem Oressa Fourwinds, {healer}."
- `stdmod_17` (PL): "Słyszałam o tym, tak."

---

## P10: Komendy NPC {keywords}

### Analiza
Klient OTClient parsuje `{word}` w wiadomościach NPC i podświetla je na niebiesko (klikalnie):
- Regex: `{([^}]+)}` w `console.lua:getHighlightedText()`
- Warunek: `speaktype.npcChat == true` (messageMody NpcFrom/NpcFromStartBlock)

### Dlaczego działa po naszych poprawkach
1. `npc:say(text, TALKTYPE_PRIVATE_NP)` → opcode 0xAA → `npcChat=true` → highlighting włączony
2. `player:getTranslation(key)` BEZ args → `fmt::vformat` pominięto → `{keyword}` zachowane
3. Tłumaczenia zachowują `{keyword}` (np. `{vocation}`, `{distance}`, `{heal}`)

### Kolizja `{keyword}` z `{fmt}`
⚠️ **Uwaga**: Składnia NPC keywords `{word}` koliduje z biblioteką fmt `{name}`.
Jeśli tłumaczenie zawiera ZARÓWNO `{keyword}` jak  `{0}` placeholder, i args są przekazane:
- `fmt::vformat` zinterpretuje `{keyword}` jako named arg → `fmt::format_error`
- Catch block zwraca surowe tłumaczenie (z `{keyword}`) + loguje warning

**Dla Oressa**: Nie ma kolizji — klucze z `{0}` (say_18, say_22) NIE mają `{keyword}`.  
**Dla przyszłości**: Tłumaczenia z `{keyword}` NIE powinny mieć `{0}` w tym samym stringu.

---

## Kolejność testowania

1. Uruchom serwer
2. Zaloguj na postać level >= 8 w Dawnporcie
3. Powiedz "hi" do Oressa → sprawdź greeting message (bez `\z`)
4. Powiedz "vocation" → 5 wiadomości z opóźnieniami
5. Powiedz "knight" → opis + pytanie o potwierdzenie
6. Powiedz "yes" → zmiana profesji + dynamiczna nazwa ("SZLACHETNY KNIGHT!")
7. Sprawdź "healing" → prawidłowa wiadomość leczenia
8. Sprawdź `{keywords}` → podświetlone na niebiesko, klikalne
