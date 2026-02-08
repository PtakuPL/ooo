local bossName = "Horestis"
local bossPosition = { x = 32943, y = 32791, z = 12 }
local Poswall1 = { x = 32941, y = 32754, z = 12 }
local Poswall2 = { x = 32942, y = 32754, z = 12 }
local Poswall3 = { x = 32943, y = 32754, z = 12 }
local Poswall4 = { x = 32944, y = 32754, z = 12 }
local failMessages = { "scripts.horestis_jars.fail_1", "scripts.horestis_jars.fail_2" }

function createWall() --creates walls
	Game.createItem(1603, 1, Poswall1)
	Game.createItem(1603, 1, Poswall2)
	Game.createItem(1603, 1, Poswall3)
	Game.createItem(1603, 1, Poswall4)
end

local horestisJars = Action()

function horestisJars.onUse(cid, item, fromPosition, itemEx, toPosition)
	local exaustedSeconds = 1
	local player = Player(cid)
	local chances = math.random(10)

	if item.actionid == 50006 then
		if item.itemid == 12511 then
			if getPlayerStorageValue(cid, Storage.TheMummysCurse.Time1) <= os.time() then
				if chances == 1 then
					doTransformItem(item.uid, 12506)
					setGlobalStorageValue(GlobalStorage.TheMummysCurse, 1)
				else
					player:sayLocalized(failMessages[math.random(#failMessages)], TALKTYPE_MONSTER_SAY)
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					setPlayerStorageValue(cid, Storage.TheMummysCurse.Time1, os.time() + exaustedSeconds * 1800)
				end
			else
				Player(cid):sendLocalizedCancelMessage("scripts.horestis_jars.wait_30min")
			end
		end
	elseif item.actionid == 50007 then
		if item.itemid == 12511 then
			if getGlobalStorageValue(GlobalStorage.TheMummysCurse) == 1 then
				if getPlayerStorageValue(cid, Storage.TheMummysCurse.Time2) <= os.time() then
					if chances == 1 then
						doTransformItem(item.uid, 12506)
						setGlobalStorageValue(GlobalStorage.TheMummysCurse, 2)
					else
						player:sayLocalized(failMessages[math.random(#failMessages)], TALKTYPE_MONSTER_SAY)
						player:getPosition():sendMagicEffect(CONST_ME_POFF)
						setPlayerStorageValue(cid, Storage.TheMummysCurse.Time2, os.time() + exaustedSeconds * 1800)
					end
				else
					Player(cid):sendLocalizedCancelMessage("scripts.horestis_jars.wait_30min")
				end
			else
				Player(cid):sendLocalizedCancelMessage("scripts.horestis_jars.break_first")
			end
		end
	elseif item.actionid == 50008 then
		if item.itemid == 12511 then
			if getGlobalStorageValue(GlobalStorage.TheMummysCurse) == 2 then
				if getPlayerStorageValue(cid, Storage.TheMummysCurse.Time3) <= os.time() then
					if chances == 1 then
						doTransformItem(item.uid, 12506)
						setGlobalStorageValue(GlobalStorage.TheMummysCurse, 3)
					else
						player:sayLocalized(failMessages[math.random(#failMessages)], TALKTYPE_MONSTER_SAY)
						player:getPosition():sendMagicEffect(CONST_ME_POFF)
						setPlayerStorageValue(cid, Storage.TheMummysCurse.Time3, os.time() + exaustedSeconds * 1800)
					end
				else
					Player(cid):sendLocalizedCancelMessage("scripts.horestis_jars.wait_30min")
				end
			else
				Player(cid):sendLocalizedCancelMessage("scripts.horestis_jars.break_second")
			end
		end
	elseif item.actionid == 50009 then
		if item.itemid == 12511 then
			if getGlobalStorageValue(GlobalStorage.TheMummysCurse) == 3 then
				if getPlayerStorageValue(cid, Storage.TheMummysCurse.Time4) <= os.time() then
					if chances == 1 then
						doTransformItem(item.uid, 12506)
						setGlobalStorageValue(GlobalStorage.TheMummysCurse, 4)
					else
						player:sayLocalized(failMessages[math.random(#failMessages)], TALKTYPE_MONSTER_SAY)
						player:getPosition():sendMagicEffect(CONST_ME_POFF)
						setPlayerStorageValue(cid, Storage.TheMummysCurse.Time4, os.time() + exaustedSeconds * 1800)
					end
				else
					Player(cid):sendLocalizedCancelMessage("scripts.horestis_jars.wait_30min")
				end
			else
				Player(cid):sendLocalizedCancelMessage("scripts.horestis_jars.break_third")
			end
		end
	elseif item.actionid == 50010 then
		if item.itemid == 12511 then
			if getGlobalStorageValue(GlobalStorage.TheMummysCurse) == 4 then
				doTransformItem(item.uid, 12506)
				-- Remover Barreira e Sumonar Boss
				doRemoveItem(getTileItemById({ x = 32941, y = 32754, z = 12 }, 3514).uid, 1)
				doRemoveItem(getTileItemById({ x = 32942, y = 32754, z = 12 }, 3514).uid, 1)
				doRemoveItem(getTileItemById({ x = 32943, y = 32754, z = 12 }, 3514).uid, 1)
				doRemoveItem(getTileItemById({ x = 32944, y = 32754, z = 12 }, 3514).uid, 1)
				Creature(cid):sayLocalized("scripts.horestis_jars.tomb_broken", TALKTYPE_MONSTER_SAY)
				Game.createMonster(bossName, bossPosition)
				addEvent(doSummonCreature, 45 * 1000, "Horestis", { x = 32942, y = 32765, z = 12 })

				addEvent(createWall, 61000 + 6 * 20 * 1800)
				addEvent(Game.createItem, 20 * 60 * 1000, 3514, { x = 32941, y = 32754, z = 12 })
				addEvent(Game.createItem, 20 * 60 * 1000, 3514, { x = 32942, y = 32754, z = 12 })
				addEvent(Game.createItem, 20 * 60 * 1000, 3514, { x = 32943, y = 32754, z = 12 })
				addEvent(Game.createItem, 20 * 60 * 1000, 3514, { x = 32944, y = 32754, z = 12 })
			else
				Player(cid):sendLocalizedCancelMessage("scripts.horestis_jars.break_fourth")
			end
		end
	end
	return true
end

horestisJars:aid(50006, 50007, 50008, 50009, 50010)
horestisJars:register()
