local config = {
	[40578] = {
		female = 1598,
		male = 1597,
		msg = "ancient aucar",
	},
}

local idol = Action()
function idol.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local choice = config[item.itemid]
	if not choice then
		return true
	end

	if not player:hasOutfit(player:getSex() == PLAYERSEX_FEMALE and choice.female or choice.male) then
		player:addOutfit(choice.female)
		player:addOutfit(choice.male)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_idol_of_tukh.msg_1", { choice.msg })
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		item:remove(1)
	else
		player:sendLocalizedCancelMessage("quests.adventures_of_galthen.you_have_already_obtained_this_outfit")
	end
	return true
end

for k, v in pairs(config) do
	idol:id(k)
end
idol:register()
