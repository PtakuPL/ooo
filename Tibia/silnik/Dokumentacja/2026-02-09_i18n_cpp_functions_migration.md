# Migracja i18n funkcji C++ — sesja 2026-02-09

## Zakres prac

Kontynuacja prac nad wielojęzycznością (i18n) w kodzie C++ serwera Canary. Pominięto tłumaczenia — skupiono się wyłącznie na przygotowaniu kodu do obsługi wielu języków.

## Zmigrowane funkcje

### 1. `getSkillName()` (tools.cpp) — 16 kluczy
- Dodano parametr `std::string_view locale = {}`
- Wszystkie nazwy umiejętności (axe fighting, sword fighting, fishing, magic level, itp.) przeniesione do `cpp.skill.*`

### 2. `getCombatName()` (tools.cpp) — 15 kluczy
- Dodano parametr locale
- Statyczna mapa `combatKeyMap` (CombatType_t → klucz i18n)
- Klucze `cpp.combat.*` (physical, fire, energy, earth, ice, holy, death, itp.)

### 3. `getWeaponName()` (tools.cpp) — 7 kluczy
- Dodano parametr locale
- Klucze `cpp.weapon.*` (sword, club, axe, distance, wand, ammunition, missile)

### 4. `getDescriptions()` (item.cpp) — ~70 kluczy, 148 zamian
- Dodano parametr locale do deklaracji i definicji
- Przeniesiono ~148 wystąpień hardcoded stringów (etykiety: "Description", "Attack", "Protection", "Body Position" itp.; wartości: "attack +", "two-handed", "oz", "fields", "faster regeneration", "Hard Drinking", "Invisibility", "Mana Shield", itp.)
- Klucze `cpp.inspect.*`

### 5. `parseAugmentDescription()` (items.cpp + item.hpp) — 8 kluczy
- Zaktualizowano zarówno metodę ItemType jak i statyczny wrapper Item
- Klucze `cpp.augment.*`

### 6. `getTradeErrorDescription()` (game.cpp) — 5 kluczy
- Dodano parametr locale do deklaracji i definicji
- Klucze `cpp.trade.*`
- Dodano locale-aware overloady `getWeightDescription()`

### 7. `sendMarketDetail()` (protocolgame.cpp) — 23 zamiany
- Dodano locale/translator na początku funkcji
- Przekazano locale do getCombatName/getSkillName/getWeaponName
- Zamieniono inline stringi: "attack +", "chance to hit +", "fields", "physical +", "seconds", "magic level", "two-handed", "oz", " and ", " at range "
- Zamieniono nazwy tier: Onslaught, Momentum, Ruse, Transcendence, Amplification → `cpp.look.tier_*`

## Statystyki

- **122 nowe klucze i18n** (306 łącznie w cpp.json)
- **62 pliki zmienione** w jednym commicie
- **52 języki zsynchronizowane** (klucze EN jako placeholder)
- **Zmodyfikowane pliki C++**: tools.cpp/hpp, item.cpp/hpp, items.cpp/hpp, game.cpp/hpp, protocolgame.cpp

## Commit
```
b127b1402 - i18n: migrate getSkillName, getCombatName, getWeaponName, getDescriptions, parseAugmentDescription, getTradeErrorDescription, sendMarketDetail
```

## Co zostało do zrobienia (przyszłe sesje)

- `getReturnMessage()` — ~65 kluczy (companion function już istnieje)
- Wiadomości gracza w player.cpp — ~25 kluczy
- Wiadomości walki/loot w game.cpp — ~28 kluczy
- Wiadomości protokołu logowania — ~15 kluczy
- Faktyczne tłumaczenia do poszczególnych języków

## Problemy

Brak — wszystkie zamiany przebiegły pomyślnie. Build sprawdzamy dopiero na GitHub Actions po zakończeniu pełnej migracji.



Now I have a clear picture. Let me plan the approach for combat messages:

Strategy: For buildMessageAsSpectator, buildMessageAsTarget, buildMessageAsAttacker — add a const std::string& locale parameter. For the spectator message cache, change from std::string to std::unordered_map<std::string, std::string> keyed by locale.

For the healing and mana loops (inline in combatChangeHealth/combatChangeMana) — get locale per tmpPlayer, build per-spectator.

Let me implement this step by step:

game.hpp — update signatures to add locale param

game.cpp — update all three buildMessageAs* implementations

game.cpp — update sendMessages caller to pass locale, change spectatorMessage to per-locale map

game.cpp — update combatChangeHealth healing loop

game.cpp — update combatChangeMana loop

I also need to handle the "hitpoints" / "hitpoint" damageString pattern for i18n, since both healing and mana messages use similar singular/plural logic for their output strings.

The key insight is that damageString gets constructed once before the spectator loop, but with i18n support, each spectator might need a different translation. Rather than rebuilding the string for each locale, I should pass just the numeric value and let the i18n format strings handle the singular/plural forms and translations together.

But I'm realizing the complexity here—damageString is embedded in larger messages like "You heal X for 50 hitpoints," so I need to decide whether to include the hitpoints/hitpoint distinction in the main format string or create separate i18n keys for just that part. Creating separate keys for every variation (with/without periods, singular/plural) is getting unwieldy, so I should simplify the approach.

The cleanest solution is to use complete sentence format strings where the entire message is localized, including proper plural handling for hitpoints. This way I can define healing messages like "You heal {0} for {1} hitpoints" with the number and target already filled in, rather than trying to compose fragments. I'm settling on using complete format strings with raw numbers passed as parameters, letting each language handle pluralization however makes sense for that locale. Since the system uses simple positional arguments, I'll just keep "hitpoints" consistent in English and trust translators to adapt as needed.

For the healing messages, I'm mapping the different scenarios—when the attacker heals a target, when someone gets healed without a source, when they heal themselves, or when they're healed by someone else—each to their own translation key so the phrasing can be natural in any language.

For spectators watching the healing happen, there are additional message variations depending on whether an attacker is involved. I'm realizing this is getting unwieldy with all the different cases, so I'm going to systematically refactor the code to handle per-spectator localization and use complete format strings for each message pattern.

Let me map out all the distinct message patterns I need to handle. For healing alone, there are six variations covering the attacker's perspective, the target's perspective in different scenarios, and what spectators see. Then mana loss adds another six or more patterns on top of that, with similar branching for who's involved and what they're experiencing. I'm mapping out the damage message patterns for attackers and spectators, with variations for critical hits and special charm effects, then I need to account for all the distinct message combinations across these different perspectives.

For implementation, I'll pass the damage numbers directly into complete format strings rather than building damageString separately—this keeps translations cleaner and lets translators handle singular/plural forms. I'm also noticing an inconsistency where healing messages include a period but damage messages don't, so I need to standardize that approach.

The plan is to refactor buildMessageAsTarget to accept a locale parameter and use i18n calls for the full message text instead of concatenating pieces together.

Refactoring message construction... Different spectators might need different locales, so caching a single spectatorMessage won't work. I could either rebuild the message for each spectator or use a map keyed by locale — but rebuilding is simpler given typical spectator counts are small. I'll remove the spectatorMessage cache parameter and just rebuild per spectator, then update the function signatures to include locale throughout.

Updating the header file... I'm realizing the spectator message caching won't work well with per-locale support, so I need to rethink this. Instead of passing a single cached string, I should use a map to store messages for each locale. But that's getting complicated—maybe the cleaner approach is to just remove the cache from the spectator function and let the caller handle caching if needed.

Refactoring the spectator message builder...

I'm setting up a cache in sendMessages that stores the built message text by locale, then checking that cache before calling buildMessageAsSpectator to avoid rebuilding the same message for multiple players with the same language preference. Since buildMessageAsSpectator already sets both the message type and text, I'll just cache the text portion and reuse it when the locale is found.

Actually, I should refactor this differently — have buildMessageAsSpectator only populate the message text when it's empty, and let the caller manage a per-locale cache map. This way the function stays simple and just checks if the string is empty before building, while the caching logic lives at the call site where it's easier to manage.

So my plan is to add a locale parameter to all three buildMessageAs* functions in both the header and implementation, then update sendMessages to maintain a cache map keyed by locale and pass the locale through to each builder. I also need to handle the damageString construction per-locale.

I'm debating whether to pass the raw damage number and build the full localized string inside each function, or refactor the signatures to accept the number instead of the pre-built string. The second approach is cleaner for i18n but requires more changes. I'll go with building a localized damageString inside each function instead—it's simpler and keeps the refactor minimal.

Now I'm thinking through the translation keys themselves. Rather than composing small fragments like "{0} hitpoints", it's better to keep full sentences as single translation keys so translators have proper context. So for healing I'd use something like "cpp.combat.you_heal_target" with the format "You heal {0} for {1} hitpoints.", and for damage I'd use "cpp.combat.target_loses_your_crit" with the full sentence including the hitpoints text.

The tradeoff is more keys to maintain, but it's cleaner for internationalization. The real issue is that the damage functions currently pass a pre-formatted damageString parameter, so I'd need to refactor to pass the raw damage number instead to make complete sentence formatting work. The simplest fix is to add int32_t realDamage as an additional parameter to the buildMessageAs* functions while keeping the existing damageString parameter, letting me use complete format strings without major refactoring.

Actually, I could just build locale-specific damage strings upfront and pass those as parameters to the message builders, using placeholder syntax in the translation keys. Building the damage string per-locale before the message loop...

Wait, I'm overcomplicating this. In reality, most servers will have everyone on English anyway, so the performance cost of per-spectator string building is negligible. The simplest approach is to add a locale parameter to each message builder, use complete i18n format strings for each message variant, pass the raw damage number as a format parameter, and let the translations handle singular/plural forms naturally.

Looking at the actual strings being passed around—healing uses "50 hitpoints.", damage uses "50 hitpoints", and mana is just "50"—I should replace each branch with a full i18n call instead of building an intermediate damageString. For the damage messages specifically, I'll need to handle the locale parameter similarly. buildMessageAs*)**: Change to use i18n format with complete sentences. The damageString parameter becomes unnecessary — we just need the damage number. But to minimize signature changes, I can keep damageString but also add locale... Actually, I can just discard damageString inside the function and use the damage values from the damage parameter. Wait, damage has primary and secondary — the realDamage is the combined total. Let me check what damageString contains in each context...

In sendMessages, damageString gets formatted as "50 hitpoints" with no period, then in buildMessageAsTarget it becomes "You lose 50 hitpoints." or includes additional context about the attacker.

For i18n, I need the raw number to slot into format strings like "You lose {0} hitpoints." or "You lose {0} hitpoints due to an attack by {1}." The cleanest approach is to change damageString to just store the number itself, then update the i18n format strings accordingly. Now I'm passing the locale through to each message builder function and caching spectator messages per locale to avoid redundant formatting. Then I'll replace all the hardcoded text in the target, attacker, and spectator message builders with i18n format calls, and do the same for the healing and mana loops where I fetch the locale per player. Finally I need to define the i18n keys for all these messages.

Defining healing message keys...

Now I'm working through the spectator view messages and realizing that the two separate keys for when someone heals themselves versus heals a target actually follow the same pattern, so I can consolidate them into one. Moving on to mana loss messages next. due to your {2}." (attacker view)

cpp.combat.you_lose_mana: "You lose {0} mana." (target, no attacker)
cpp.combat.you_lose_mana_own: "You lose {0} mana due to your own {1}." (target, self)
cpp.combat.you_lose_mana_by: "You lose {0} mana due to an {1} by {2}." (target, by other)
cpp.combat.spectator_loses_mana: "{0} loses {1} mana." (spectator, no attacker)
cpp.combat.spectator_loses_mana_own: "{0} loses {1} mana due to {2} own attack." (spectator, own)
cpp.combat.spectator_loses_mana_by: "{0} loses {1} mana due to an {2} by {3}." (spectator, by other)
Now looking at the damage messages for the target, which follow a similar pattern with hitpoints instead of mana. I'm noticing that the code determines whether to include "critical" as a separate modifier from the article, so I need to handle those as distinct parameters in the message templates.

Actually, I'm realizing the code constructs these messages with fixed patterns — either "due to an attack" or "due to a critical attack" — so it makes more sense to have separate message keys for each case rather than trying to parameterize the critical modifier. I should define two distinct keys for regular and critical attacks, and handle the Soulpit Crit suffix as a separate game mechanic label appended to the message.

For the extension suffix that gets appended after the main message, that's already a formatted string so I'll leave it as-is for now since translating those charm names is a separate concern.

Now I need to think through the actual implementation strategy to keep this clean and minimize bugs. The key is making sure each damage message path — the healing loop, mana loop, and both target/attacker message builders — all get the locale they need and use the i18n formatting consistently.

For the signature changes, I'll need to update both the header and implementation files. The healing and mana loops have inline messages in their respective functions, so those will need the locale passed through.

On the singular/plural issue with hitpoint vs hitpoints, I think the cleanest approach is to just use "hitpoints" consistently and let translators handle singular forms in their own languages rather than trying to manage it in the code. I'm reconsidering the approach — using complete sentences with "hitpoints" consistently is simpler than trying to handle singular/plural forms. Now let me look at how the mana messages are structured to apply the same pattern there.

The mana damage message shows the target losing mana due to the player's attack, with an optional extra string for special mechanics. I need to decide whether to handle the extra string as a separate format call or include it conditionally in the same key, and I'm leaning toward keeping it simple by just appending it when present rather than creating multiple translation keys.

Now I'm ready to implement the actual changes. I need to modify the function signatures in the header to accept a locale parameter, then update the sendMessages implementation to pass that locale through and construct the damage string properly while maintaining backward compatibility.

Implementing the code changes... I'm realizing I need to be more careful about the structure here. The damageString is already computed before the loop starts, so for internationalization with complete sentences, I really just need the realDamage value. The function signatures still expect damageString as a parameter, but I can keep it minimal—just the number plus hitpoints notation—and embed it directly into the i18n format strings instead of building it separately inside each function. I'll simplify this by just passing the raw number as damageString and moving "hitpoints" into the localized format strings themselves. That way the healing logic follows the same pattern—just convert the health change to a string and let the translation handle the unit label.

For mana, the damageString is already correct as just the number. Now I'm mapping out all the i18n keys I'll need for the healing messages...

Defining the healing message keys... Defining localization strings for combat messages... I'm reviewing how the code constructs these messages—it uses possessive pronouns for own attacks and articles plus attacker descriptions for others' attacks, with "critical" inserted conditionally based on whether it was a crit.

Now I need to finalize the localization keys and make sure the pronoun gets passed as a parameter so translations can handle gender-specific possessives correctly. I'm mapping out the three message keys needed for the i18n system: one for when there's no attacker, one for self-healing that includes the reflexive pronoun, and one for healing another target. The reflexive pronoun needs to be passed as a parameter to handle different genders properly. I'm simplifying the approach by passing the pronoun as a parameter and letting translators handle the context themselves. Now I'm finalizing the translation key structure with separate entries for each perspective—the attacker's view of healing someone, the target's view of being healed, and variations for self-healing and healing from others.

Defining the spectator view keys and mana loss messages... Continuing with the localization strings for combat messages...

I'm looking at the spectator view variants now, which show how damage appears to other players watching the fight. There's also some logic I'm working through for how the spectator message should handle cases where a player damages themselves. I'm setting up the localization keys for damage messages—covering cases where a player loses HP from their own attack, a critical attack, or an attack by another player. Now I need to implement this carefully, starting with updating the function signatures in the header file, then moving through the implementation in the cpp file where I'll need to handle the healing loop, mana loop, and the message formatting logic.

For the sendMessages function, I'm thinking through whether I need an unordered_map or if a simpler approach would work. Since most servers have players on the same locale, I could optimize for that common case rather than building a full locale-to-message map for every spectator message. per-spectator. The performance impact is negligible. So let me remove the spectatorMessage cache entirely.

For buildMessageAsSpectator, I'll remove the std::string &spectatorMessage parameter entirely and always build the message. This simplifies the code.

Wait, changing the parameter list breaks the API. Let me keep the parameter but ignore it (just always build fresh). Or... let me change it to accept locale and use a different caching mechanism.

Actually, I think the simplest approach is:

Keep spectatorMessage but don't use it
Always build fresh message based on locale
Or better:

Change spectatorMessage to std::unordered_map<std::string, std::string> &spectatorMessageCache
Look up by locale, if cache hit, use it; otherwise build and cache
This gives the same performance optimization while supporting multiple locales.

Now let me verify that realDamage is available in sendMessages — yes, it's a parameter passed in, so I can use it directly when building the damage string. For the function signatures, I'll keep changes minimal and update buildMessageAsSpectator to accept a locale-based cache instead of a single message string. Now I'm setting up the per-locale caching strategy by passing the locale parameter through to the build functions, then implementing the actual changes across the header and the three message-building functions before tackling the healing and mana loops. for the existing buildMessageAsSpectator, the spectatorMessage is used as a cache string that's populated once and reused. The behavior is:

If I pass a per-locale reference from the map, this works perfectly! The first spectator with locale "en" builds it, subsequent "en" spectators reuse it. A spectator with locale "pl" triggers a new build.

The only change inside the function is using i18n with the locale parameter instead of hardcoded strings. The cache mechanism stays the same!

Now I'm looking at the healing section more carefully to see how the spectator messages are constructed there. Finishing the spectator message construction and sending it to the player. I'm reconsidering the caching approach for locale-specific messages—initially thinking about using a map per locale, but deciding it's simpler to just build the message fresh for each spectator rather than maintaining that cache.

Since healing events are infrequent and spectator counts are usually small, the performance impact is negligible. Now I'm planning the implementation in stages: updating the function signatures in the header, then systematically replacing each message-building function and the callers that pass locale information through the system, followed by updating the healing and mana loops, and finally adding the necessary localization keys.

Let me start writing the Python scripts to make these changes safely. For the header file, I'll add the locale parameter with a default value to each of the three functions. Then I'll tackle the message builders, making sure to handle the spectator message caching properly—either using a map-based cache per locale or simplifying by removing the cache entirely.

Actually, I'm realizing the inline loops for healing and mana are getting too complex with per-locale caching. It's cleaner to just build the message fresh for each spectator rather than trying to cache across locales in a tight loop. The string concatenation overhead is negligible.

Now I'm reconsidering the attack message format in buildMessageAsAttacker — specifically how the critical hit indicator and spacing are handled.

Looking at the original code, there's a double space bug when it's not a critical hit: "due to your " << (damage.critical ? "critical " : " ") << "attack." produces either "due to your critical attack." or "due to your attack." with an extra space. I should fix this in the i18n version by using proper conditional text rather than replicating the spacing issue.

Now I need to write a Python script to handle all the combat message changes in game.cpp. The main functions to update are sendMessages (converting damageString to just the number and adding locale), buildMessageAsTarget, buildMessageAsAttacker, buildMessageAsSpectator (with locale parameter), and the healing and mana loops. Let me carefully go through the current state of these functions to make sure I'm working with the latest version.

Actually, I should double-check whether I need to include <unordered_map> for the locale caching. Since game.cpp is a large file, it likely already has the necessary headers, and std::map would work fine anyway. For a small number of locales, std::map is probably more efficient than std::unordered_map due to cache locality.

Now I'm going to write a Python script that will handle the replacement. I need to modify the sendMessages function to use the locale cache instead of checking the player's locale directly each time.

Writing the replacement script... Building the damage message logic... I'm building the spectator message by checking if it's empty, then constructing a description of the damage with critical hit formatting and proper grammar, accounting for whether the attacker is the target themselves or an external creature. Building the spectator message... Finishing up the spectator message formatting and setting the message type, then moving into the target-specific message builder which handles damage calculations differently based on whether the attacker is a monster with special abilities like soul pit. Building the message construction function... I'm finishing up the damage message logic by adding the soul pit critical text if needed, then setting the message type and text. Now I'm moving

Evaluating...