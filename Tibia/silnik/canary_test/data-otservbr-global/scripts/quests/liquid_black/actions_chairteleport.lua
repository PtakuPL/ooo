local teleportplayer = { x = 33269, y = 31832, z = 1 }

local chairteleport = Action()

function chairteleport.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor) == 2 then
		player:teleportTo(teleportplayer)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_chairteleport.msg_2")
		player:setStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor, 3)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_chairteleport.msg_1")
	end

	return true
end

chairteleport:uid(57744)
chairteleport:register()
