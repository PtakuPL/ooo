local seashellId = 14066

local seashellKey = Action()

function seashellKey.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target:getId() ~= seashellId then
		return true
	end

	local bookChance = math.random(0, 100)
	if bookChance < 85 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_seashell_key.msg_1")
		item:remove(1)
		return true
	end

	local bookColor = math.random(0, 1000)
	if bookColor < 333 then
		player:addItem(14173)
	elseif bookColor >= 667 then
		player:addItem(14174)
	else
		player:addItem(14175)
	end
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_seashell_key.msg_2")
	item:remove(1)
	return true
end

seashellKey:id(14009)
seashellKey:register()
