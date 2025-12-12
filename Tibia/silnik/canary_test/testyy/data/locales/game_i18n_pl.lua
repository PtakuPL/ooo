-- ============================================
-- GAME I18N TRANSLATIONS - POLSKI
-- ============================================
-- Tłumaczenia gry na język polski
-- Klucze wysyłane przez serwer, klient tłumaczy używając tr()
--
-- Konwencje:
--   npc.*  = Dialogi NPC
--   nv.*   = Głosy NPC (krzyki)
--   mv.*   = Głosy potworów
--   mn.*   = Nazwy potworów
--   it.*   = Nazwy przedmiotów
--   id.*   = Opisy przedmiotów
--   sp.*   = Nazwy zaklęć
--   cm.*   = Wiadomości walki
--   sys.*  = Wiadomości systemowe
--
-- Wygenerowano: 2025-12-12
-- ============================================

local gameTranslations = {
  -- ==========================================
  -- DIALOGI NPC (npc.*)
  -- ==========================================
  
  -- The Oracle (Rookgaard)
  ["npc.the_oracle.say_1"] = "WRÓĆ KIEDY OSIĄGNIESZ POZIOM 8!",
  ["npc.the_oracle.say_2"] = "JUŻ WYBRAŁEŚ SWOJĄ DROGĘ. ŻEGNAJ!",
  ["npc.the_oracle.say_3"] = "GDZIE CHCESZ ROZPOCZĄĆ SWOJĄ PODRÓŻ? {VENORE}, {THAIS} CZY {CARLIN}?",
  ["npc.the_oracle.say_4"] = "PROSZĘ WYBIERZ PRAWIDŁOWE MIASTO: {VENORE}, {THAIS} LUB {CARLIN}.",
  ["npc.the_oracle.say_5"] = "PROSZĘ WYBIERZ PRAWIDŁOWĄ PROFESJĘ: {RYCERZ}, {PALADYN}, {CZARODZIEJ} LUB {DRUID}.",
  ["npc.the_oracle.say_6"] = "NIECH TAK BĘDZIE! IDŹ I WYPEŁNIJ SWOJE PRZEZNACZENIE!",
  ["npc.the_oracle.say_7"] = "WIĘC JAKĄ PROFESJĘ WYBIERASZ?",
  
  -- Cipfried (Świątynia Rookgaard)
  ["npc.cipfried.say_1"] = "Witaj w świątyni, młody poszukiwaczu przygód!",
  ["npc.cipfried.say_2"] = "Niech bogowie cię chronią.",
  ["npc.cipfried.say_3"] = "Odwiedź mnie gdy będziesz ranny, mogę uleczyć twoje rany.",
  
  -- Ogólne NPC sklepowe
  ["npc.shop.greeting"] = "Witaj w moim sklepie! Czym mogę służyć?",
  ["npc.shop.farewell"] = "Dziękuję za wizytę! Wracaj wkrótce!",
  ["npc.shop.trade_offer"] = "Zobacz moje oferty {handlowe}.",
  ["npc.shop.no_money"] = "Nie masz wystarczająco złota.",
  ["npc.shop.inventory_full"] = "Nie masz wystarczającej pojemności.",
  
  -- ==========================================
  -- GŁOSY NPC (nv.*) - co NPC krzyczą co jakiś czas
  -- ==========================================
  ["nv.1"] = "Świeże mięso! Kupujcie świeże mięso!",
  ["nv.2"] = "Najlepsze bronie w mieście!",
  ["nv.3"] = "Mikstury! Runy! Wszystko czego potrzebuje poszukiwacz przygód!",
  ["nv.4"] = "Zatrudniam odważnych poszukiwaczy przygód!",
  ["nv.5"] = "Usługi bankowe dostępne!",
  
  -- ==========================================
  -- GŁOSY POTWORÓW (mv.*) - co mówią potwory
  -- ==========================================
  
  -- Smoki
  ["mv.dragon.1"] = "CZUJĘ ZAPACH STRACHU!",
  ["mv.dragon.2"] = "SPŁONIESZ!",
  ["mv.dragon.3"] = "POCZUJ MOJ OGIEŃ!",
  
  -- Władcy Smoków
  ["mv.dragon_lord.1"] = "UKŁOŃ SIĘ PRZED MOJĄ POTĘGĄ!",
  ["mv.dragon_lord.2"] = "ZNISZCZENIE!",
  
  -- Demony
  ["mv.demon.1"] = "TWOJA DUSZA BĘDZIE MOJA!",
  ["mv.demon.2"] = "DRŻYJ ŚMIERTELNIKU!",
  ["mv.demon.3"] = "ZNISZCZENIE NADCHODZI!",
  
  -- Szczury
  ["mv.rat.1"] = "*pisk*",
  ["mv.rat.2"] = "*pisk* *pisk*",
  
  -- Wilki
  ["mv.wolf.1"] = "*wycie*",
  
  -- Orkowie
  ["mv.orc.1"] = "Grow Udh!",
  ["mv.orc.2"] = "Ulua Bull!",
  
  -- Trolle
  ["mv.troll.1"] = "Grrrr!",
  ["mv.troll.2"] = "Luuuuudzieee!",
  
  -- Cyklopy
  ["mv.cyclops.1"] = "Wyglądaaasz smaaaacznie!",
  ["mv.cyclops.2"] = "Głoooooodny!",
  
  -- Giganci
  ["mv.giant.1"] = "ZMIAŻDŻĘ MAŁĄ RZECZ!",
  ["mv.giant.2"] = "FII FAJ FO FUM!",
  
  -- ==========================================
  -- NAZWY POTWORÓW (mn.*) - zlokalizowane nazwy stworzeń
  -- ==========================================
  
  ["mn.rat"] = "Szczur",
  ["mn.cave_rat"] = "Jaskiniowy Szczur",
  ["mn.wolf"] = "Wilk",
  ["mn.deer"] = "Jeleń",
  ["mn.rabbit"] = "Królik",
  ["mn.snake"] = "Wąż",
  ["mn.spider"] = "Pająk",
  ["mn.poison_spider"] = "Jadowity Pająk",
  ["mn.giant_spider"] = "Gigantyczny Pająk",
  ["mn.troll"] = "Troll",
  ["mn.goblin"] = "Goblin",
  ["mn.orc"] = "Ork",
  ["mn.orc_warrior"] = "Ork Wojownik",
  ["mn.cyclops"] = "Cyklop",
  ["mn.dragon"] = "Smok",
  ["mn.dragon_lord"] = "Władca Smoków",
  ["mn.demon"] = "Demon",
  ["mn.archemon"] = "Arcydemon",
  
  -- ==========================================
  -- NAZWY PRZEDMIOTÓW (it.*) - zlokalizowane nazwy przedmiotów
  -- ==========================================
  
  ["it.magic_sword"] = "Magiczny Miecz",
  ["it.fire_sword"] = "Ognisty Miecz",
  ["it.golden_helmet"] = "Złoty Hełm",
  ["it.health_potion"] = "Mikstura Lecznicza",
  ["it.mana_potion"] = "Mikstura Many",
  ["it.great_health_potion"] = "Wielka Mikstura Lecznicza",
  ["it.sudden_death_rune"] = "Runa Nagłej Śmierci",
  ["it.backpack"] = "Plecak",
  
  -- ==========================================
  -- NAZWY ZAKLĘĆ (sp.*) - zlokalizowane nazwy zaklęć
  -- ==========================================
  
  ["sp.exori"] = "Exori",
  ["sp.exori_gran"] = "Exori Gran",
  ["sp.exura"] = "Exura",
  ["sp.exura_gran"] = "Exura Gran",
  ["sp.exura_vita"] = "Exura Vita",
  ["sp.exevo_gran_mas_flam"] = "Wielka Kula Ognia",
  ["sp.utani_hur"] = "Pośpiech",
  
  -- ==========================================
  -- WIADOMOŚCI WALKI (cm.*)
  -- ==========================================
  
  ["cm.hit"] = "%s trafia cię zadając %d obrażeń!",
  ["cm.miss"] = "%s chybił!",
  ["cm.critical"] = "Trafienie krytyczne! %s zadaje %d obrażeń!",
  ["cm.heal"] = "Uleczyłeś się o %d punktów życia.",
  ["cm.mana_spent"] = "Użyłeś %d many.",
  ["cm.level_up"] = "Awansowałeś na poziom %d!",
  ["cm.skill_up"] = "Rozwinąłeś umiejętność %s.",
  
  -- ==========================================
  -- WIADOMOŚCI SYSTEMOWE (sys.*)
  -- ==========================================
  
  ["sys.welcome"] = "Witaj w %s! Ostatnie logowanie: %s.",
  ["sys.logout"] = "Zostałeś wylogowany.",
  ["sys.connection_lost"] = "Utracono połączenie. Połącz się ponownie.",
  ["sys.server_message"] = "[Wiadomość Serwera] %s",
}

-- Merge with existing locale
if locale and locale.translation then
  for key, value in pairs(gameTranslations) do
    locale.translation[key] = value
  end
else
  -- If called before locale is set, store for later
  _G.gameTranslations_pl = gameTranslations
end
