-- ============================================
-- GAME I18N TRANSLATIONS - ENGLISH (BASE)
-- ============================================
-- This file contains server-side game translations
-- Keys are sent by server, client translates using tr()
--
-- Conventions:
--   npc.*  = NPC dialogs
--   nv.*   = NPC voices (yells)
--   mv.*   = Monster voices
--   mn.*   = Monster names
--   it.*   = Item names
--   id.*   = Item descriptions
--   sp.*   = Spell names
--   cm.*   = Combat messages
--   sys.*  = System messages
--
-- Generated: 2025-12-12
-- ============================================

local gameTranslations = {
  -- ==========================================
  -- NPC DIALOGS (npc.*)
  -- ==========================================
  
  -- The Oracle (Rookgaard)
  ["npc.the_oracle.say_1"] = "COME BACK WHEN YOU REACH LEVEL 8!",
  ["npc.the_oracle.say_2"] = "YOU HAVE ALREADY CHOSEN YOUR PATH. FAREWELL!",
  ["npc.the_oracle.say_3"] = "WHERE DO YOU WANT TO START YOUR JOURNEY? {VENORE}, {THAIS} OR {CARLIN}?",
  ["npc.the_oracle.say_4"] = "PLEASE CHOOSE A VALID CITY: {VENORE}, {THAIS} OR {CARLIN}.",
  ["npc.the_oracle.say_5"] = "PLEASE CHOOSE A VALID VOCATION: {KNIGHT}, {PALADIN}, {SORCERER} OR {DRUID}.",
  ["npc.the_oracle.say_6"] = "SO BE IT! GO FORTH AND FULFILL YOUR DESTINY!",
  ["npc.the_oracle.say_7"] = "THEN WHAT PROFESSION DO YOU WANT?",
  
  -- Cipfried (Rookgaard Temple)
  ["npc.cipfried.say_1"] = "Welcome to the temple, young adventurer!",
  ["npc.cipfried.say_2"] = "May the gods protect you.",
  ["npc.cipfried.say_3"] = "Visit me when you are hurt, I can heal your wounds.",
  
  -- Generic shop NPCs
  ["npc.shop.greeting"] = "Welcome to my shop! How can I help you?",
  ["npc.shop.farewell"] = "Thank you for your visit! Come back soon!",
  ["npc.shop.trade_offer"] = "Take a look at my {trade} offers.",
  ["npc.shop.no_money"] = "You don't have enough gold.",
  ["npc.shop.inventory_full"] = "You don't have enough capacity.",
  
  -- ==========================================
  -- NPC VOICES (nv.*) - what NPCs yell periodically
  -- ==========================================
  ["nv.1"] = "Fresh meat! Get your fresh meat here!",
  ["nv.2"] = "Best weapons in town!",
  ["nv.3"] = "Potions! Runes! Everything an adventurer needs!",
  ["nv.4"] = "Hiring brave adventurers!",
  ["nv.5"] = "Bank services available!",
  
  -- ==========================================
  -- MONSTER VOICES (mv.*) - what monsters say
  -- ==========================================
  
  -- Dragons
  ["mv.dragon.1"] = "I SMELL FEAR!",
  ["mv.dragon.2"] = "YOU WILL BURN!",
  ["mv.dragon.3"] = "FEEL MY FLAMES!",
  
  -- Dragon Lords
  ["mv.dragon_lord.1"] = "BOW BEFORE MY MIGHT!",
  ["mv.dragon_lord.2"] = "DESTRUCTION!",
  
  -- Demons
  ["mv.demon.1"] = "YOUR SOUL WILL BE MINE!",
  ["mv.demon.2"] = "TREMBLE MORTAL!",
  ["mv.demon.3"] = "DESTRUCTION AWAITS!",
  
  -- Rats
  ["mv.rat.1"] = "*squeak*",
  ["mv.rat.2"] = "*squeak* *squeak*",
  
  -- Wolves
  ["mv.wolf.1"] = "*howl*",
  
  -- Orcs
  ["mv.orc.1"] = "Grow Udh!",
  ["mv.orc.2"] = "Ulua Bull!",
  
  -- Trolls  
  ["mv.troll.1"] = "Groar!",
  ["mv.troll.2"] = "Huummmaaaannnsss!",
  
  -- Cyclops
  ["mv.cyclops.1"] = "Youuuu looook taaastyyyy!",
  ["mv.cyclops.2"] = "Huuuungryyyy!",
  
  -- Giants
  ["mv.giant.1"] = "CRUSH LITTLE THING!",
  ["mv.giant.2"] = "FEE FI FO FUM!",
  
  -- ==========================================
  -- MONSTER NAMES (mn.*) - localized creature names
  -- ==========================================
  -- Note: These are EXAMPLES - full list needs to be generated
  
  ["mn.rat"] = "Rat",
  ["mn.cave_rat"] = "Cave Rat",
  ["mn.wolf"] = "Wolf",
  ["mn.deer"] = "Deer",
  ["mn.rabbit"] = "Rabbit",
  ["mn.snake"] = "Snake",
  ["mn.spider"] = "Spider",
  ["mn.poison_spider"] = "Poison Spider",
  ["mn.giant_spider"] = "Giant Spider",
  ["mn.troll"] = "Troll",
  ["mn.goblin"] = "Goblin",
  ["mn.orc"] = "Orc",
  ["mn.orc_warrior"] = "Orc Warrior",
  ["mn.cyclops"] = "Cyclops",
  ["mn.dragon"] = "Dragon",
  ["mn.dragon_lord"] = "Dragon Lord",
  ["mn.demon"] = "Demon",
  ["mn.archemon"] = "Archdemon",
  
  -- ==========================================
  -- ITEM NAMES (it.*) - localized item names
  -- ==========================================
  -- Note: These are EXAMPLES - full list needs to be generated
  
  ["it.magic_sword"] = "Magic Sword",
  ["it.fire_sword"] = "Fire Sword",
  ["it.golden_helmet"] = "Golden Helmet",
  ["it.health_potion"] = "Health Potion",
  ["it.mana_potion"] = "Mana Potion",
  ["it.great_health_potion"] = "Great Health Potion",
  ["it.sudden_death_rune"] = "Sudden Death Rune",
  ["it.backpack"] = "Backpack",
  
  -- ==========================================
  -- SPELL NAMES (sp.*) - localized spell names
  -- ==========================================
  
  ["sp.exori"] = "Exori",
  ["sp.exori_gran"] = "Exori Gran",
  ["sp.exura"] = "Exura",
  ["sp.exura_gran"] = "Exura Gran",
  ["sp.exura_vita"] = "Exura Vita",
  ["sp.exevo_gran_mas_flam"] = "Great Fireball",
  ["sp.utani_hur"] = "Haste",
  
  -- ==========================================
  -- COMBAT MESSAGES (cm.*)
  -- ==========================================
  
  ["cm.hit"] = "%s hits you for %d damage!",
  ["cm.miss"] = "%s misses you!",
  ["cm.critical"] = "Critical hit! %s deals %d damage!",
  ["cm.heal"] = "You healed yourself for %d hitpoints.",
  ["cm.mana_spent"] = "You used %d mana.",
  ["cm.level_up"] = "You advanced to level %d!",
  ["cm.skill_up"] = "You advanced in %s.",
  
  -- ==========================================
  -- SYSTEM MESSAGES (sys.*)
  -- ==========================================
  
  ["sys.welcome"] = "Welcome to %s! Last login: %s.",
  ["sys.logout"] = "You have been logged out.",
  ["sys.connection_lost"] = "Connection lost. Please reconnect.",
  ["sys.server_message"] = "[Server Message] %s",
}

-- Merge with existing locale if this is not base English
if locale and locale.translation then
  for key, value in pairs(gameTranslations) do
    locale.translation[key] = value
  end
end

-- For English base locale, we export translations for fallback
_G.gameTranslations_en = gameTranslations
