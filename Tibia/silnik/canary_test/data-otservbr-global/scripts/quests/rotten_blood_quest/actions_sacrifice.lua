local sacrificialPlate = Action()

function sacrificialPlate.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local access = player:kv():scoped("rotten-blood-quest"):get("access") or 0
	if access > 3 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sacrifice.msg_1")
		return true
	end

	if player:getItemCount(32594) < 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sacrifice.msg_2")
		return false
	end

	if access == 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sacrifice.msg_3")
		player:kv():scoped("rotten-blood-quest"):set("access", 2)
		return true
	end

	if player:removeItem(32594, 1) then
		if access == 2 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sacrifice.msg_4")
		elseif access == 3 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sacrifice.msg_5")
		end
		player:kv():scoped("rotten-blood-quest"):set("access", access + 1)
	end

	return true
end

sacrificialPlate:id(43891)
sacrificialPlate:register()
