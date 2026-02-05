local galthensTree = Action()
function galthensTree.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local hasExhaustion = player:kv():get("galthens-satchel") or 0
	local messageKey = "scripts.galthens_tree.empty"
	if hasExhaustion < os.time() then
		local container = player:addItem(36813)
		container:addItem(36810, 1)
		player:kv():set("galthens-satchel", os.time() + 30 * 24 * 60 * 60)
		messageKey = "scripts.galthens_tree.found_satchel"
	end

	player:teleportTo(Position(32396, 32520, 7))
	player:getPosition():sendMagicEffect(CONST_ME_WATERSPLASH)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, messageKey)

	return true
end

galthensTree:position(Position(32366, 32542, 8))
galthensTree:register()
