local fount = {
	[1] = { transformid = 22166, pos = Position(33421, 32383, 12), revert = 2094 },
	[2] = { transformid = 22167, pos = Position(33422, 32383, 12), revert = 2095 },
	[3] = { transformid = 22168, pos = Position(33421, 32384, 12), revert = 2096 },
	[4] = { transformid = 22169, pos = Position(33422, 32384, 12), revert = 2097 },
}

local ferumbrasAscendantSacrifice = Action()
function ferumbrasAscendantSacrifice.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target.actionid == 53805 or Tile(Position(33415, 32379, 12)):getItemById(22163) or player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Fount) >= 4 then
		return false
	end
	if item.itemid == 22158 then
		if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Bone) >= 1 then
			player:sayLocalized("scripts.actions_sacrifice.say_4", TALKTYPE_MONSTER_SAY)
			return true
		end
		player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Bone, 1)
	elseif item.itemid == 22170 then
		if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Ring2) >= 1 then
			player:sayLocalized("scripts.actions_sacrifice.say_3", TALKTYPE_MONSTER_SAY)
			return true
		end
		player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Ring2, 1)
	elseif item.itemid == 9685 then
		if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Vampire) >= 1 then
			player:sayLocalized("scripts.actions_sacrifice.say_2", TALKTYPE_MONSTER_SAY)
			return true
		end
		player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Vampire, 1)
	elseif item.itemid == 3661 then
		if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Flower) >= 1 then
			player:sayLocalized("scripts.actions_sacrifice.say_1", TALKTYPE_MONSTER_SAY)
			return true
		end
		player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Flower, 1)
	end
	if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Fount) == 3 then
		for i = 1, #fount do
			local fount = fount[i]
			local founts = Tile(fount.pos):getItemById(fount.revert)
			founts:transform(fount.transformid)
			founts:setActionId(100)
		end
		local statue = Tile(Position(33415, 32379, 12)):getItemById(22163)
		if statue then
			statue:transform(22161)
		end
	end
	if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Fount) < 0 then
		player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Fount, 0)
	end
	player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Fount, player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Fount) + 1)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sacrifice.msg_1", { item:getName() })
	toPosition:sendMagicEffect(CONST_ME_DRAWBLOOD)
	item:remove(1)
	return true
end

ferumbrasAscendantSacrifice:id(3661, 9685, 22158, 22170)
ferumbrasAscendantSacrifice:register()
