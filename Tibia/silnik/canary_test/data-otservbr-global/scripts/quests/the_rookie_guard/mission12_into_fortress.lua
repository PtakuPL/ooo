-- The Rookie Guard Quest - Mission 12: Into The Fortress

local missionTiles = {
	[50354] = {
		{
			states = { 1 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.AcademyChest,
				state = -1,
			},
			message = "quests.rookie_guard.m12.chest_items",
			arrowPosition = { x = 32109, y = 32187, z = 8 },
		},
		{
			states = { 1 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.AcademyChest,
				state = 1,
			},
			message = "quests.rookie_guard.m12.items_infiltrate",
			newState = 2,
		},
	},
	[50355] = {
		{
			states = { 2 },
			message = "quests.rookie_guard.m12.orc_break",
		},
	},
	[50356] = {
		{
			states = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 },
			condition = function(player)
				return player:getOutfit().lookType ~= 5
			end,
			message = "quests.rookie_guard.m12.guard_pass",
			walkTo = { x = 1, y = 0, z = 0 },
		},
		{
			states = { 4 },
			condition = function(player)
				return player:getOutfit().lookType == 5
			end,
			message = "quests.rookie_guard.m12.sneaked_in",
			newState = 5,
			walkTo = { x = -1, y = 0, z = 0 },
		},
	},
	[50357] = {
		{
			states = { 5 },
			message = "quests.rookie_guard.m12.distraction_bone_1",
		},
	},
	[50358] = {
		{
			states = { 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 },
			condition = function(player)
				return Tile(Position(31977, 32150, 7)):getItemById(12792) ~= nil
			end,
			message = "quests.rookie_guard.m12.distraction_bone_1",
			teleportTo = { x = 31977, y = 32155, z = 7 },
		},
	},
	[50359] = {
		{
			states = { 6 },
			newState = 7,
			message = "quests.rookie_guard.m12.interior",
		},
	},
	[50360] = {
		{
			states = { 7 },
			message = "quests.rookie_guard.m12.kitchen",
		},
	},
	[50361] = {
		{
			states = { 7 },
			message = "quests.rookie_guard.m12.no_poison_yet",
			walkTo = { x = 0, y = -1, z = 0 },
		},
	},
	[50362] = {
		{
			states = { 8 },
			message = "quests.rookie_guard.m12.trap_ready",
		},
	},
	[50363] = {
		{
			states = { 11 },
			message = "quests.rookie_guard.m12.approaching",
		},
	},
}

-- Mission tutorial tiles

local missionGuide = MoveEvent()

function missionGuide.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	-- Skip if not was started or finished
	if missionState == -1 then
		return true
	end
	local tile = missionTiles[item.actionid]
	for i = 1, #tile do
		local extraState = tile[i].extra == nil or player:getStorageValue(tile[i].extra.storage) == tile[i].extra.state
		local condition = tile[i].condition == nil or tile[i].condition(player)
		-- Check if the tile is active
		if table.find(tile[i].states, missionState) and extraState and condition then
			-- Check delayed notifications (message/arrow)
			if not isTutorialNotificationDelayed(player) then
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, tile[i].message)
				if tile[i].arrowPosition then
					Position(tile[i].arrowPosition):sendMagicEffect(CONST_ME_TUTORIALARROW)
				end
			end
			-- Update state
			if tile[i].newState then
				player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, tile[i].newState)
			end
			-- Walk to relative position
			if tile[i].walkTo then
				local walkTo = tile[i].walkTo
				player:teleportTo(Position(position.x + walkTo.x, position.y + walkTo.y, position.z + walkTo.z), true)
			end
			-- Teleport to position
			if tile[i].teleportTo then
				player:teleportTo(Position(tile[i].teleportTo), false)
			end
			break
		end
	end
	return true
end

for index, value in pairs(missionTiles) do
	missionGuide:aid(index)
end
missionGuide:register()

-- Treasure chest (gather final mission items)

local reward = {
	containerId = 2853,
	itemIds = {
		12788,
		12789,
		12784,
		12674,
	},
}

local treasureChest = Action()

function treasureChest.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	-- Skip if not was started
	if missionState == -1 then
		return true
	end
	if missionState >= 1 and missionState <= 13 then
		local chestState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.AcademyChest)
		local chestTimer = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.AcademyChestTimer)
		if chestState == -1 or chestTimer - os.time() <= 0 then
			local container = Game.createItem(reward.containerId)
			for i = #reward.itemIds, 1, -1 do
				container:addItem(reward.itemIds[i], 1)
			end
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_1", { container:getArticle(), container:getName() })
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.AcademyChest, 1)
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.AcademyChestTimer, os.time() + 24 * 60 * 60)
			player:addItemEx(container, true, CONST_SLOT_WHEREEVER)
		else
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.common.item_is_empty", { item:getName() })
		end
	end
	return true
end

treasureChest:uid(40056)
treasureChest:register()

-- Rolling pin (Knock out peeing orc)

local function orcRecovery(position)
	local tile = Tile(position)
	if tile then
		local item = tile:getItemById(12791)
		if item then
			item:transform(12790, 1)
		end
	end
end

local rollingPin = Action()

function rollingPin.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	if missionState >= 2 and missionState <= 13 and itemEx.itemid == 12790 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_2")
		if missionState == 2 then
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 3)
			player:addExperience(50, true)
		end
		itemEx:transform(12791, 1)
		addEvent(orcRecovery, 60000, itemEx:getPosition())
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_3")
	end
	return true
end

rollingPin:id(12789)
rollingPin:register()

-- Unconscious orc (Disguise like orc)

local unconsciousOrc = Action()

function unconsciousOrc.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	if missionState >= 3 and missionState <= 13 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_4")
		if missionState == 3 then
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 4)
		end
		local conditionOutfit = Condition(CONDITION_OUTFIT)
		conditionOutfit:setTicks(300000)
		conditionOutfit:setOutfit({ lookType = 5 })
		player:addCondition(conditionOutfit)
	end
	return true
end

unconsciousOrc:id(12791)
unconsciousOrc:register()

-- Fleshy bone (Distract elite orc guard)

local monstersList = {
	{ name = "Running Elite Orc Guard", amount = 1 },
	{ name = "Wild Dog", amount = 8 },
}
local monsters = {}

local function eliteOrcGuardRecovery(position)
	local spectators = Game.getSpectators(position, false, true, 2, 2, 2, 2)
	if #spectators > 0 then
		local hidePosition = Position(31977, 32154, 7)
		for i = 1, #spectators do
			spectators[i]:teleportTo(hidePosition, false)
		end
	end
	if monsters then
		for i = 1, #monsters do
			monsters[i]:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			monsters[i]:remove()
		end
	end
	Game.createItem(12792, 1, position)
end

local fleshyBone = Action()

function fleshyBone.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	if missionState >= 5 and itemEx.itemid == 12792 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_5")
		if missionState == 5 then
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 6)
			player:addExperience(50, true)
		end
		local position = itemEx:getPosition()
		local spawnPosition = Position(position.x, position.y + 1, position.z)
		itemEx:remove()
		monsters = {}
		for i = 1, #monstersList do
			if i == 2 then
				spawnPosition.y = spawnPosition.y + 2
			end
			for j = 1, monstersList[i].amount do
				monsters[#monsters + 1] = Game.createMonster(monstersList[i].name, spawnPosition)
			end
		end
		position:sendMagicEffect(CONST_ME_TELEPORT)
		addEvent(eliteOrcGuardRecovery, 120000, position)
	end
	return true
end

fleshyBone:id(12674)
fleshyBone:register()

-- Wasp poison flask (Poison cauldron)

local poisonFlask = Action()

function poisonFlask.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	if missionState == 7 and itemEx.actionid == 40012 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_6")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 8)
		player:removeItem(12784, 1)
		player:addExperience(50, true)
	end
	return true
end

poisonFlask:id(12784)
poisonFlask:register()

-- Tarantula trap (Slow furious orc berserker)

local taranturaTrap = Action()

function taranturaTrap.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	target = Tile(topos):getTopCreature()
	if missionState >= 8 and target:getName() == "Furious Orc Berserker" then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_7")
		if missionState == 8 then
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 9)
		end
		local conditionSlow = Condition(CONDITION_PARALYZE)
		conditionSlow:setParameter(CONDITION_PARAM_TICKS, 20000)
		conditionSlow:setFormula(-0.3, 0, -0.45, 0)
		target:addCondition(conditionSlow)
	end
	return true
end

taranturaTrap:id(12788)
taranturaTrap:register()

-- Kraknaknork lair teleport

local bossLairTeleport = MoveEvent()

function bossLairTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	-- Skip if not was started or finished
	if missionState == -1 then
		return true
	end
	if missionState >= 9 then
		local spectators = Game.getSpectators(position, false, false, 2, 2, 2, 2)
		for i = 1, #spectators do
			if not spectators[i]:isPlayer() and spectators[i]:getName() == "Furious Orc Berserker" then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_8")
				player:teleportTo(fromPosition, true)
				position:sendMagicEffect(CONST_ME_TELEPORT)
				fromPosition:sendMagicEffect(CONST_ME_TELEPORT)
				return true
			end
		end
		if missionState == 9 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_9")
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 10)
		end
		local toPosition = Position(31980, 32173, 10)
		player:teleportTo(toPosition, false)
		position:sendMagicEffect(CONST_ME_TELEPORT)
		toPosition:sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end

bossLairTeleport:uid(40057)
bossLairTeleport:register()

-- Energy barriers

local energyBarriers = {
	[40058] = {
		position = { x = 31974, y = 32174, z = 10 },
		teleportTo = { x = 31977, y = 32174, z = 10 },
		message = "quests.rookie_guard.m12.energy_barrier",
	},
	[40059] = {
		position = { x = 31962, y = 32174, z = 10 },
		teleportTo = { x = 31964, y = 32174, z = 10 },
	},
	[40060] = {
		position = { x = 31960, y = 32184, z = 10 },
		teleportTo = { x = 31958, y = 32184, z = 10 },
	},
	[40061] = {
		position = { x = 31953, y = 32187, z = 10 },
		teleportTo = { x = 31955, y = 32187, z = 10 },
	},
	[40062] = {
		position = { x = 31972, y = 32183, z = 10 },
		teleportTo = { x = 31970, y = 32183, z = 10 },
	},
	[40063] = {
		position = { x = 31952, y = 32174, z = 10 },
		teleportTo = { x = 31954, y = 32174, z = 10 },
	},
}

local missionEnergyBarriers = MoveEvent()

function missionEnergyBarriers.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local energyBarrier = energyBarriers[item.uid]
	local teleportPosition = Position(energyBarrier.teleportTo)
	player:teleportTo(teleportPosition, false)
	position:sendMagicEffect(CONST_ME_PURPLEENERGY)
	teleportPosition:sendMagicEffect(CONST_ME_PURPLEENERGY)
	if energyBarrier.message then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, energyBarrier.message)
	end
	return true
end

for index, value in pairs(energyBarriers) do
	missionEnergyBarriers:uid(index)
end
missionEnergyBarriers:register()

-- Levers

local levers = {
	[40064] = {
		barrier = 40058,
		message = "quests.rookie_guard.m12.lever_barrier",
	},
	[40065] = {
		barrier = 40059,
	},
	[40066] = {
		barrier = 40060,
	},
	[40067] = {
		barrier = 40061,
	},
	[40068] = {
		barrier = 40062,
	},
	[40069] = {
		barrier = 40063,
		newState = 11,
	},
}

local function energyBarrierRestore(barrierUID)
	local energyBarrier = Tile(energyBarriers[barrierUID].position):getItemById(12796)
	if not energyBarrier then
		energyBarrier = Game.createItem(12796, 1, energyBarriers[barrierUID].position)
		energyBarrier:setAttribute(ITEM_ATTRIBUTE_UNIQUEID, barrierUID)
	end
end

local missionLevers = Action()

function missionLevers.onUse(player, item, position, itemEx, toPosition)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	if missionState >= 10 then
		local lever = levers[item.uid]
		local energyBarrier = Tile(energyBarriers[lever.barrier].position):getItemById(12796)
		if energyBarrier then
			energyBarrier:getPosition():sendMagicEffect(CONST_ME_PURPLEENERGY)
			energyBarrier:remove()
			if lever.message then
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, lever.message)
			else
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_10")
			end
			if missionState == 10 and lever.newState then
				player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, lever.newState)
			end
			addEvent(energyBarrierRestore, 60000, lever.barrier)
		else
			player:sayLocalized("quests.mission12_into_fortress.say_1", TALKTYPE_MONSTER_SAY, false, player, position)
		end
	end
	return true
end

for index, value in pairs(levers) do
	missionLevers:uid(index)
end
missionLevers:register()

-- Kraknaknork room

local boss = {
	uid = nil,
	fight = nil,
	roomCenter = { x = 31937, y = 32170, z = 10 },
}

local function finishBossFight(playerUid, bossUid)
	local player = Player(playerUid)
	-- Kick out the player
	if player then
		local roomExitPosition = Position(31980, 32173, 10)
		player:teleportTo(roomExitPosition, false)
		roomExitPosition:sendMagicEffect(CONST_ME_TELEPORT)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_11")
		local health, maxHealth = player:getHealth(), player:getBaseMaxHealth()
		-- Heal the player if needed
		if health < maxHealth then
			player:addHealth((maxHealth - health), COMBAT_HEALING)
		end
	end
	local boss = Creature(bossUid)
	-- Despawn the boss
	if boss then
		boss:getPosition():sendMagicEffect(CONST_ME_POFF)
		boss:remove()
	end
end

-- Kraknaknork room enter teleport

local enterBossRoomTeleport = MoveEvent()

function enterBossRoomTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	-- Skip if not was started or finished
	if missionState == -1 then
		return true
	end
	if missionState >= 11 then
		local spectators = Game.getSpectators(Position(boss.roomCenter), false, true, 8, 8, 5, 5)
		-- Check if there is a player inside the room
		if #spectators > 0 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_12")
			player:teleportTo(fromPosition, false)
			return true
		end
		-- Spawn the boss
		local bossCreature = Game.createMonster("Kraknaknork", Position(31930, 32170, 10))
		local bossDeath = CreatureEvent("KraknaknorkDeath")
		function bossDeath.onDeath(player, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
			stopEvent(boss.fight)
		end

		bossDeath:register()
		bossCreature:registerEvent("KraknaknorkDeath")
		boss.uid = bossCreature.uid
		-- Teleport the player to the room
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_13")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 12)
		local roomPosition = Position(31944, 32174, 10)
		player:teleportTo(roomPosition, false)
		position:sendMagicEffect(CONST_ME_TELEPORT)
		roomPosition:sendMagicEffect(CONST_ME_TELEPORT)
		-- Start boss fight timer
		boss.fight = addEvent(finishBossFight, 5 * 60 * 1000, player.uid, bossCreature.uid)
	end
	return true
end

enterBossRoomTeleport:uid(40070)
enterBossRoomTeleport:register()

-- Kraknaknork room exit teleport

local exitBossRoomTeleport = MoveEvent()

function exitBossRoomTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	-- Cancel boss fight timer
	stopEvent(boss.fight)
	-- Teleport the player
	local roomExitPosition = Position(31954, 32174, 10)
	player:teleportTo(roomExitPosition, false)
	position:sendMagicEffect(CONST_ME_TELEPORT)
	roomExitPosition:sendMagicEffect(CONST_ME_TELEPORT)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_14")
	-- Despawn the boss
	local boss = Creature(boss.uid)
	if boss then
		boss:getPosition():sendMagicEffect(CONST_ME_POFF)
		boss:remove()
	end
	return true
end

exitBossRoomTeleport:uid(40071)
exitBossRoomTeleport:register()

-- Kraknaknork treasure room enter teleport

local enterTreasureRoomTeleport = MoveEvent()

function enterTreasureRoomTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	if missionState == 12 then
		local spectators = Game.getSpectators(Position(boss.roomCenter), false, false, 8, 8, 5, 5)
		-- Check the boss do not exist
		if #spectators > 0 then
			for i = 1, #spectators do
				if not spectators[i]:isPlayer() and spectators[i]:getName() == "Kraknaknork" then
					player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_15")
					player:teleportTo(fromPosition, false)
					position:sendMagicEffect(CONST_ME_TELEPORT)
					fromPosition:sendMagicEffect(CONST_ME_TELEPORT)
					return false
				end
			end
		end
		-- Teleport the player to the treasure room
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 13)
		local treasureRoomPosition = Position(31932, 32171, 11)
		player:teleportTo(treasureRoomPosition, false)
		position:sendMagicEffect(CONST_ME_TELEPORT)
		treasureRoomPosition:sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end

enterTreasureRoomTeleport:uid(40072)
enterTreasureRoomTeleport:register()

-- Boss treasure chests (Rewards: small ruby and 2 platinum coins)

local CHEST_ID = {
	LEFT = 1,
	RIGHT = 2,
}

local chests = {
	[40073] = {
		id = CHEST_ID.LEFT,
		item = {
			id = 3030,
			amount = 1,
		},
	},
	[40074] = {
		id = CHEST_ID.RIGHT,
		item = {
			id = 3035,
			amount = 2,
		},
	},
}

local bossChests = Action()

function bossChests.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	-- Skip if not was started
	if missionState == -1 then
		return true
	end
	if missionState == 13 then
		local chest = chests[item.uid]
		local chestsState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.KraknaknorkChests)
		local hasUsedChest = testFlag(chestsState, chest.id)
		if not hasUsedChest then
			local reward = Game.createItem(chest.item.id, chest.item.amount)
			if reward:getCount() == 1 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_16", { reward:getArticle(), reward:getName() })
			elseif reward:getCount() > 1 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_17", { reward:getCount(), reward:getPluralName() })
			end
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.KraknaknorkChests, chestsState + chest.id)
			player:addItemEx(reward, true, CONST_SLOT_WHEREEVER)
		else
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.common.item_is_empty", { item:getName() })
		end
	end
	return true
end

bossChests:uid(40073, 40074)
bossChests:register()

-- Kraknaknork treasure room exit teleport

local exitTreasureRoomTeleport = MoveEvent()

function exitTreasureRoomTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12)
	if missionState == 13 then
		local health, maxHealth = player:getHealth(), player:getBaseMaxHealth()
		-- Heal the player if needed
		if health < maxHealth then
			player:addHealth((maxHealth - health), COMBAT_HEALING)
		end
		-- Teleport the player to the orcland exit
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_18")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 14)
		local exitPosition = Position(32016, 32150, 7)
		player:teleportTo(exitPosition, false)
		position:sendMagicEffect(CONST_ME_TELEPORT)
		exitPosition:sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end

exitTreasureRoomTeleport:uid(40075)
exitTreasureRoomTeleport:register()

-- Orc fortress and Kraknaknork lair chests

local CHEST_ID = {
	FORTRESS_TREASURE_CHEST = 1,
	FORTRESS_TRUNK = 2,
	LAIR_TREASURE_CHEST = 4,
}

local chests = {
	[40079] = {
		id = CHEST_ID.FORTRESS_TREASURE_CHEST,
		item = {
			id = 3606,
			amount = 30,
		},
	},
	[40080] = {
		id = CHEST_ID.FORTRESS_TRUNK,
		item = {
			id = 7876,
			amount = 2,
		},
	},
	[40081] = {
		id = CHEST_ID.LAIR_TREASURE_CHEST,
		item = {
			id = 7876,
			amount = 1,
		},
	},
}

local orcFortressChests = Action()

function orcFortressChests.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10)
	-- Skip if not was started
	if missionState == -1 then
		return true
	end
	local chest = chests[item.uid]
	local chestsState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.OrcFortressChests)
	local hasOpenedChest = testFlag(chestsState, chest.id)
	if not hasOpenedChest then
		local reward = Game.createItem(chest.item.id, chest.item.amount)
		if reward:getCount() == 1 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_19", { reward:getArticle(), reward:getName() })
		elseif reward:getCount() > 1 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission12_into_fortress.msg_20", { reward:getCount(), reward:getPluralName() })
		end
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.OrcFortressChests, chestsState + chest.id)
		player:addItemEx(reward, true, CONST_SLOT_WHEREEVER)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.common.item_is_empty", { item:getName() })
	end
	return true
end

orcFortressChests:uid(40079, 40080, 40081)
orcFortressChests:register()
