local signs = {
	{
		pos = { x = 33095, y = 32244, z = 9 },
		storage = Storage.Quest.U10_70.LionsRock.InnerSanctum.SnakeSign,
		messageKey1 = "scripts.lions_rock_signs.snake_1",
		messageKey2 = "scripts.lions_rock_signs.snake_2",
	},
	{
		pos = { x = 33128, y = 32300, z = 9 },
		storage = Storage.Quest.U10_70.LionsRock.InnerSanctum.LizardSign,
		messageKey1 = "scripts.lions_rock_signs.lizard_1",
		messageKey2 = "scripts.lions_rock_signs.lizard_2",
	},
	{
		pos = { x = 33109, y = 32329, z = 9 },
		storage = Storage.Quest.U10_70.LionsRock.InnerSanctum.ScorpionSign,
		messageKey1 = "scripts.lions_rock_signs.scorpion_1",
		messageKey2 = "scripts.lions_rock_signs.scorpion_2",
	},
	{
		pos = { x = 33127, y = 32340, z = 9 },
		storage = Storage.Quest.U10_70.LionsRock.InnerSanctum.HyenaSign,
		messageKey1 = "scripts.lions_rock_signs.hyena_1",
		messageKey2 = "scripts.lions_rock_signs.hyena_2",
	},
}

-- Lions rock entrance
local lionsRockEntrance = MoveEvent()

function lionsRockEntrance.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U10_70.LionsRock.Questline) >= 4 then
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:teleportTo({ x = 33122, y = 32308, z = 8 })
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_lions_rock.msg_1")
		player:getPosition():sendMagicEffect(CONST_ME_THUNDER)
	else
		player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
		player:teleportTo(fromPosition, true)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_lions_rock.msg_2")
	end
	return true
end

lionsRockEntrance:position({ x = 33128, y = 32308, z = 8 })
lionsRockEntrance:register()

-- Rock translation scroll
local checkPos = {
	{ x = 33118, y = 32246, z = 9 },
	{ x = 33119, y = 32246, z = 9 },
	{ x = 33120, y = 32246, z = 9 },
	{ x = 33118, y = 32247, z = 9 },
	{ x = 33120, y = 32247, z = 9 },
	{ x = 33118, y = 32248, z = 9 },
	{ x = 33119, y = 32248, z = 9 },
	{ x = 33120, y = 32248, z = 9 },
}
local lionsRockTranslationScroll = MoveEvent()

function lionsRockTranslationScroll.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local amphoraPos = Position(33119, 32247, 9)
	local amphoraID = 21945
	local amphoraBrokenID = 21946
	local function reset()
		local brokenAmphora = Tile(amphoraPos):getItemById(amphoraBrokenID)
		if brokenAmphora then
			brokenAmphora:transform(amphoraID)
		end
	end

	if player:getStorageValue(Storage.Quest.U10_70.LionsRock.Questline) == 4 then
		local amphora = Tile(amphoraPos):getItemById(amphoraID)
		if amphora then
			amphora:transform(amphoraBrokenID)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_lions_rock.msg_3")
			player:setStorageValue(Storage.Quest.U10_70.LionsRock.Questline, 5)
			player:addItem(21467, 1)
			amphoraPos:sendMagicEffect(CONST_ME_GROUNDSHAKER)
			addEvent(reset, 15 * 1000)
		end
	end
	return true
end

for a = 1, #checkPos do
	lionsRockTranslationScroll:position(checkPos[a])
end
lionsRockTranslationScroll:register()

-- Lions rock sign
local lionsRockSigns = MoveEvent()

function lionsRockSigns.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return
	end
	local setting
	for c = 1, #signs do
		setting = signs[c]
		if player:getStorageValue(setting.storage) < 1 and player:getItemCount(21467) >= 1 and player:getPosition() == Position(setting.pos) then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, setting.messageKey1)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, setting.messageKey2)
			player:setStorageValue(setting.storage, 1)
			player:setStorageValue(Storage.Quest.U10_70.LionsRock.Questline, player:getStorageValue(Storage.Quest.U10_70.LionsRock.Questline) + 1)
		end
	end
	return true
end

for b = 1, #signs do
	lionsRockSigns:position(signs[b].pos)
end

lionsRockSigns:register()

-- Lions rock message
local lionsRockMessage = MoveEvent()

function lionsRockMessage.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return
	end
	if player:getStorageValue(Storage.Quest.U10_70.LionsRock.InnerSanctum.Message) < 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_lions_rock.msg_4")
		player:setStorageValue(Storage.Quest.U10_70.LionsRock.InnerSanctum.Message, 1)
	end
	return true
end

lionsRockMessage:position({ x = 33080, y = 32274, z = 10 })
lionsRockMessage:register()
