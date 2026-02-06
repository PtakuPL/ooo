local config = {
	[23538] = { name = "vortexion", mountId = 94, tameMessage = "scripts.usable_mount_items.tame_sparkion" },
	[23684] = { name = "neon sparkid", mountId = 98, tameMessage = "scripts.usable_mount_items.tame_neon_sparkid" },
	[23685] = { name = "vortexion", mountId = 99, tameMessage = "scripts.usable_mount_items.tame_vortexion" },
	[32629] = { name = "haze", mountId = 162, achievement = "Nothing but Hot Air", tameMessage = "scripts.usable_mount_items.tame_haze" },
}

local usableItemMounts = Action()

function usableItemMounts.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not player:isPremium() then
		player:sendCancelMessage(RETURNVALUE_YOUNEEDPREMIUMACCOUNT)
		return true
	end

	local useItem = config[item.itemid]
	if player:hasMount(useItem.mountId) then
		return false
	end

	if useItem.achievement then
		player:addAchievement(useItem.achievement)
	end

	if table.contains({ 23538, 23684, 23685 }, item.itemid) then
		player:addAchievementProgress("Vortex Tamer", 3)
	end

	player:addMount(useItem.mountId)
	player:addAchievement("Natural Born Cowboy")
	player:sayLocalized(useItem.tameMessage, TALKTYPE_MONSTER_SAY)
	item:remove(1)
	return true
end

for k, v in pairs(config) do
	usableItemMounts:id(k)
end

usableItemMounts:register()
