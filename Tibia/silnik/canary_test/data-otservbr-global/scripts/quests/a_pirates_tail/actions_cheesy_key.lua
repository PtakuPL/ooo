local config = {
	sorcerer = {
		id = 1367,
		name = "Bladespark",
	},
	druid = {
		id = 1364,
		name = "Mossmasher",
	},
	paladin = {
		id = 1366,
		name = "Sandscourge",
	},
	knight = {
		id = 1365,
		name = "Snowbash",
	},
}

local action = Action()

function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local vocation = config[player:getVocation():getBase():getName():lower()]
	if not vocation then
		return true
	end
	if player:hasFamiliar(vocation.id) then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_cheesy_key.msg_1", { vocation.name })
		return false
	end

	player:addFamiliar(vocation.id)
	item:remove()
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_cheesy_key.msg_2", { vocation.name })
	return true
end

action:id(35508)
action:register()
