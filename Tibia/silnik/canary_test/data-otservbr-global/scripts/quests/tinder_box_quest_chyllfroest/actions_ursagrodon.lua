local config = {
	item1 = 20358,
	item2 = 20359,
	item3 = 20360,
	item4 = 20361,
	percentage = 90,
	storageKey = Storage.Quest.U10_37.TinderBoxQuestChyllfroest.Obedience,
}

local function revertIce(toPosition)
	local tile = toPosition:getTile()
	if tile then
		local thing = tile:getItemById(config.item4)
		if thing then
			thing:transform(config.item1)
		end
	end
end

local ursagrodon = Action()

function ursagrodon.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local rand = math.random(1, 100)
	local currentDate = os.date("*t")

	if currentDate.month < 4 or currentDate.month > 5 or (currentDate.month == 5 and currentDate.day > 1) then
		return player:sendLocalizedCancelMessage("quests.tinder_box_quest_chyllfroest.this_can_only_be_used_between")
	end

	if target.itemid == config.item1 or target.itemid == config.item2 or target.itemid == config.item3 then
		if player:getStorageValue(config.storageKey) > 0 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_ursagrodon.msg_1")
			return true
		end

		if rand <= config.percentage then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_ursagrodon.msg_2")
			item:remove(1)
			target:transform(config.item4)
			addEvent(revertIce, 600 * 1000, toPosition)
		else
			if target.itemid == config.item1 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_ursagrodon.msg_3")
				target:transform(config.item2)
			elseif target.itemid == config.item2 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_ursagrodon.msg_4")
				target:transform(config.item3)
			elseif target.itemid == config.item3 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_ursagrodon.msg_5")
				target:transform(config.item4)
				item:remove(1)
				player:addMount(38)
				player:setStorageValue(config.storageKey, 1)
				addEvent(revertIce, 600 * 1000, toPosition)
			end
		end
	end
	return true
end

ursagrodon:id(20355)
ursagrodon:register()
