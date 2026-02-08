local foods = {
	[3606] = { 6, "scripts.foods.sound_gulp" }, -- egg
	[3250] = { 5, "scripts.foods.sound_crunch" }, -- carrot
	[3577] = { 15, "scripts.foods.sound_munch" }, -- meat
	[21145] = { 15, "scripts.foods.sound_burp" }, -- bottle of glooth wine
	[21144] = { 15, "scripts.foods.sound_slurp" }, -- bowl of glooth soup
	[21143] = { 10, "scripts.foods.sound_munch" }, -- bowl of glooth soup
	[3578] = { 12, "scripts.foods.sound_munch" }, -- fish
	[3579] = { 10, "scripts.foods.sound_mmmm" }, -- salmon
	[23535] = { 30, "scripts.foods.sound_mmmm" }, -- energy bar
	[23545] = { 30, "scripts.foods.sound_mmmm" }, -- energy drink
	[3580] = { 17, "scripts.foods.sound_munch" }, -- northern pike
	[3581] = { 4, "scripts.foods.sound_gulp" }, -- shrimp
	[3582] = { 30, "scripts.foods.sound_chomp" }, -- ham
	[3583] = { 60, "scripts.foods.sound_chomp" }, -- dragon ham
	[3584] = { 5, "scripts.foods.sound_yum" }, -- pear
	[3585] = { 6, "scripts.foods.sound_yum" }, -- red apple
	[3586] = { 13, "scripts.foods.sound_yum" }, -- orange
	[3587] = { 8, "scripts.foods.sound_yum" }, -- banana
	[3588] = { 1, "scripts.foods.sound_yum" }, -- blueberry
	[3589] = { 18, "scripts.foods.sound_slurp" }, -- coconut
	[3590] = { 1, "scripts.foods.sound_yum" }, -- cherry
	[3591] = { 2, "scripts.foods.sound_yum" }, -- strawberry
	[3592] = { 9, "scripts.foods.sound_yum" }, -- grapes
	[904] = { 9, "scripts.foods.sound_hum" }, -- cream cake
	[3593] = { 20, "scripts.foods.sound_yum" }, -- melon
	[3594] = { 17, "scripts.foods.sound_munch" }, -- pumpkin
	[3595] = { 5, "scripts.foods.sound_crunch" }, -- carrot
	[3596] = { 6, "scripts.foods.sound_munch" }, -- tomato
	[3597] = { 9, "scripts.foods.sound_crunch" }, -- corncob
	[3598] = { 2, "scripts.foods.sound_crunch" }, -- cookie
	[3599] = { 2, "scripts.foods.sound_munch" }, -- candy cane
	[3600] = { 10, "scripts.foods.sound_crunch" }, -- bread
	[3601] = { 3, "scripts.foods.sound_crunch" }, -- roll
	[3602] = { 8, "scripts.foods.sound_crunch" }, -- brown bread
	[3607] = { 9, "scripts.foods.sound_smack" }, -- cheese
	[3723] = { 9, "scripts.foods.sound_munch" }, -- white mushroom
	[3724] = { 4, "scripts.foods.sound_munch" }, -- red mushroom
	[3725] = { 22, "scripts.foods.sound_munch" }, -- brown mushroom
	[3726] = { 30, "scripts.foods.sound_munch" }, -- orange mushroom
	[3727] = { 9, "scripts.foods.sound_munch" }, -- wood mushroom
	[3728] = { 6, "scripts.foods.sound_munch" }, -- dark mushroom
	[3729] = { 12, "scripts.foods.sound_munch" }, -- some mushrooms
	[3730] = { 3, "scripts.foods.sound_munch" }, -- some mushrooms
	[3731] = { 36, "scripts.foods.sound_munch" }, -- fire mushroom
	[3732] = { 5, "scripts.foods.sound_munch" }, -- green mushroom
	[5096] = { 4, "scripts.foods.sound_yum" }, -- mango
	[20310] = { 4, "scripts.foods.sound_mmmm" }, -- christmas cookie tray
	[5678] = { 8, "scripts.foods.sound_gulp" }, -- tortoise egg
	[6125] = { 8, "scripts.foods.sound_gulp" }, -- tortoise egg from nargor
	[6277] = { 10, "scripts.foods.sound_mmmm" }, -- cake
	[6278] = { 15, "scripts.foods.sound_mmmm" }, -- decorated cake
	[6392] = { 12, "scripts.foods.sound_mmmm" }, -- valentine's cake
	[6393] = { 15, "scripts.foods.sound_mmmm" }, -- cream cake
	[6500] = { 20, "scripts.foods.sound_mmmm" }, -- gingerbread man
	[6541] = { 6, "scripts.foods.sound_gulp" }, -- coloured egg (yellow)
	[6542] = { 6, "scripts.foods.sound_gulp" }, -- coloured egg (red)
	[6543] = { 6, "scripts.foods.sound_gulp" }, -- coloured egg (blue)
	[6544] = { 6, "scripts.foods.sound_gulp" }, -- coloured egg (green)
	[6545] = { 6, "scripts.foods.sound_gulp" }, -- coloured egg (purple)
	[6569] = { 1, "scripts.foods.sound_mmmm" }, -- candy
	[6574] = { 5, "scripts.foods.sound_mmmm" }, -- bar of chocolate
	[7158] = { 15, "scripts.foods.sound_munch" }, -- rainbow trout
	[7159] = { 13, "scripts.foods.sound_munch" }, -- green perch
	[229] = { 2, "scripts.foods.sound_yum" }, -- ice cream cone (crispy chocolate chips)
	[7373] = { 2, "scripts.foods.sound_yum" }, -- ice cream cone (velvet vanilla)
	[7374] = { 2, "scripts.foods.sound_yum" }, -- ice cream cone (sweet strawberry)
	[7375] = { 2, "scripts.foods.sound_yum" }, -- ice cream cone (chilly cherry)
	[7376] = { 2, "scripts.foods.sound_yum" }, -- ice cream cone (mellow melon)
	[7377] = { 2, "scripts.foods.sound_yum" }, -- ice cream cone (blue-barian)
	[836] = { 4, "scripts.foods.sound_crunch" }, -- walnut
	[841] = { 4, "scripts.foods.sound_crunch" }, -- peanut
	[901] = { 60, "scripts.foods.sound_munch" }, -- marlin
	[169] = { 9, "scripts.foods.sound_urgh" }, -- scarab cheese
	[8010] = { 10, "scripts.foods.sound_gulp" }, -- potato
	[8011] = { 5, "scripts.foods.sound_yum" }, -- plum
	[8012] = { 1, "scripts.foods.sound_yum" }, -- raspberry
	[8013] = { 1, "scripts.foods.sound_urgh" }, -- lemon
	[8014] = { 7, "scripts.foods.sound_munch" }, -- cucumber
	[8015] = { 5, "scripts.foods.sound_crunch" }, -- onion
	[8016] = { 1, "scripts.foods.sound_gulp" }, -- jalapeño pepper
	[8017] = { 5, "scripts.foods.sound_munch" }, -- beetroot
	[8019] = { 11, "scripts.foods.sound_yum" }, -- chocolate cake
	[8177] = { 7, "scripts.foods.sound_slurp" }, -- yummy gummy worm
	[8197] = { 5, "scripts.foods.sound_crunch" }, -- bulb of garlic
	[9537] = { 0, "scripts.foods.sound_headache" }, -- headache pill
	[10329] = { 15, "scripts.foods.sound_yum" }, -- rice ball
	[10453] = { 3, "scripts.foods.sound_urgh" }, -- terramite eggs
	[10219] = { 10, "scripts.foods.sound_mmmm" }, -- crocodile steak
	[11459] = { 20, "scripts.foods.sound_yum" }, -- pineapple
	[11460] = { 10, "scripts.foods.sound_munch" }, -- aubergine
	[11461] = { 8, "scripts.foods.sound_crunch" }, -- broccoli
	[11462] = { 9, "scripts.foods.sound_crunch" }, -- cauliflower
	[11681] = { 55, "scripts.foods.sound_gulp" }, -- ectoplasmic sushi
	[11682] = { 18, "scripts.foods.sound_yum" }, -- dragonfruit
	[11683] = { 2, "scripts.foods.sound_munch" }, -- peas
	[12310] = { 20, "scripts.foods.sound_crunch" }, -- haunch of boar
	[13992] = { 55, "scripts.foods.sound_munch" }, -- sandfish
	[14084] = { 14, "scripts.foods.sound_urgh" }, -- larvae
	[14085] = { 15, "scripts.foods.sound_munch" }, -- deepling filet
	[14681] = { 60, "scripts.foods.sound_mmmm" }, -- anniversary cake
	[15795] = { 0, "scripts.foods.sound_phew" }, -- stale mushroom beer
	[16103] = { 33, "scripts.foods.sound_munch" }, -- mushroom pie
	[17457] = { 10, "scripts.foods.sound_urgh" }, -- insectoid eggs
	[17820] = { 15, "scripts.foods.sound_smack" }, -- soft cheese
	[17821] = { 12, "scripts.foods.sound_smack" }, -- rat cheese
	[21146] = { 25, "scripts.foods.sound_chomp" }, -- glooth steak
	[22187] = { 25, "scripts.foods.sound_chomp" }, -- Roasted Meat
	[22185] = { 8, "scripts.foods.sound_yum" }, -- pickle pear
	[24382] = { 20, "scripts.foods.sound_urgh" }, -- bug meat
	[24383] = { 10, "scripts.foods.sound_gulp" }, -- cave turnip
	[24396] = { 60, "scripts.foods.sound_mmmm" }, -- birthday cake
	[24948] = { 10, "scripts.foods.sound_slurp" }, -- bottle of tibian wine
	[25692] = { 15, "scripts.foods.sound_mmmmm" }, -- fresh fruit
	[30198] = { 40, "scripts.foods.sound_mmmmm" }, -- meringue cake
	[30202] = { 15, "scripts.foods.sound_slurp" }, -- winterberry liquor
	[31560] = { 40, "scripts.foods.sound_slurp" }, -- goanna meat
	[32069] = { 15, "scripts.foods.sound_slurp" }, -- candy floss
	[37530] = { 10, "scripts.foods.sound_slurp" }, -- bottle of champagne
	[37531] = { 5, "scripts.foods.sound_mmmm" }, -- candy floss
	[37532] = { 15, "scripts.foods.sound_mmmm" }, -- ice cream cone
	[37533] = { 60, "scripts.foods.sound_mmmm" }, -- birthday layer cake
	[48116] = { 35, "scripts.foods.sound_yum" }, -- gummy rotworms
	[48251] = { 25, "scripts.foods.sound_yum" }, -- wafer paper flower
	[48252] = { 45, "scripts.foods.sound_yum" }, -- brigadeiro
	[48253] = { 45, "scripts.foods.sound_yum" }, -- beijinho
	[48254] = { 65, "scripts.foods.sound_yum" }, -- churro heart
	[48255] = { 125, "scripts.foods.sound_yum" }, -- lime tart
	[48256] = { 605, "scripts.foods.sound_yum" }, -- pastry dragon
	[48273] = { 185, "scripts.foods.sound_yum" }, -- taiyaki ice cream
	[48508] = { 125, "scripts.foods.sound_yum" }, -- amber souvenir
	[48509] = { 120, "scripts.foods.sound_yum" }, -- resinous fish fin
	[48511] = { 120, "scripts.foods.sound_yum" }, -- resin parasite
	[48544] = { 124, "scripts.foods.sound_yum" }, -- wad of fairy floss
}

local food = Action()

function food.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local itemFood = foods[item.itemid]
	if not itemFood then
		return false
	end

	local condition = player:getCondition(CONDITION_REGENERATION, CONDITIONID_DEFAULT)
	if condition and math.floor(condition:getTicks() / 1000 + (itemFood[1] * 12)) >= 1200 then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "scripts.foods.msg_1")
		return true
	end

	player:feed(itemFood[1] * 12)
	player:sayLocalized(itemFood[2], TALKTYPE_MONSTER_SAY)
	player:updateSupplyTracker(item)
	player:getPosition():sendSingleSoundEffect(SOUND_EFFECT_TYPE_ACTION_EAT, player:isInGhostMode() and nil or player)
	item:remove(1)
	return true
end

for index, value in pairs(foods) do
	food:id(index)
end

food:register()
