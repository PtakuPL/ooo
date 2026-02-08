local outfitConfig = {
	-- soil guardian
	[16252] = { female = 514, male = 516, effect = CONST_ME_GREEN_RINGS },
	[16253] = { female = 514, male = 516, addon = 1, effect = CONST_ME_GREEN_RINGS, achievement = "Funghitastic" },
	[16254] = { female = 514, male = 516, addon = 2, effect = CONST_ME_GREEN_RINGS, achievement = "Funghitastic" },

	-- crystal warlord
	[16255] = { female = 513, male = 512, effect = CONST_ME_GIANTICE },
	[16256] = { female = 513, male = 512, addon = 1, effect = CONST_ME_GIANTICE, achievement = "Crystal Clear" },
	[16257] = { female = 513, male = 512, addon = 2, effect = CONST_ME_GIANTICE, achievement = "Crystal Clear" },

	-- makeshift warrior
	[27655] = { female = 1043, male = 1042, whiteText = "scripts.usable_outfit_items.makeshift_warrior_plan" },
	[27657] = { female = 1043, male = 1042, addon = 1, achievement = "Cobbled and Patched", whiteText = "scripts.usable_outfit_items.makeshift_warrior_shield" },
	[27656] = { female = 1043, male = 1042, addon = 2, achievement = "Cobbled and Patched", whiteText = "scripts.usable_outfit_items.makeshift_warrior_helmet" },

	-- hand of the inquisition
	[31738] = { female = 1244, male = 1243, addon = 1, effect = CONST_ME_HOLYAREA, achievement = "Inquisition's Arm" },
	[31737] = { female = 1244, male = 1243, addon = 2, effect = CONST_ME_HOLYAREA, achievement = "Inquisition's Arm" },

	-- poltergeist
	[32630] = { female = 1271, male = 1270, addon = 1, effect = CONST_ME_BLUE_GHOST, achievement = "Mainstreet Nightmare", orangeText = "scripts.usable_outfit_items.poltergeist_hood" },
	[32631] = { female = 1271, male = 1270, addon = 2, effect = CONST_ME_BLUE_GHOST, achievement = "Mainstreet Nightmare", orangeText = "scripts.usable_outfit_items.poltergeist_claw" },

	-- revenant
	[34075] = { female = 1323, male = 1322, addon = 1, effect = CONST_ME_HOLYAREA, achievement = "Unleash the Beast", orangeText = "scripts.usable_outfit_items.revenant_beast" },
	[34076] = { female = 1323, male = 1322, addon = 2, effect = CONST_ME_HOLYAREA, achievement = "Unleash the Beast", orangeText = "scripts.usable_outfit_items.revenant_power" },

	-- rascoohan
	[35595] = { female = 1372, male = 1371, addon = 1, achievement = "Honorary Rascoohan", orangeText = "scripts.usable_outfit_items.rascoohan_raccoon" },
	[35695] = { female = 1372, male = 1371, addon = 2, achievement = "Honorary Rascoohan", orangeText = "scripts.usable_outfit_items.rascoohan_trash" },

	-- fire-fighter
	[39544] = { female = 1569, male = 1568, addon = 1, achievement = "Friendly Fire", orangeText = "scripts.usable_outfit_items.firefighter_fight" },
	[39545] = { female = 1569, male = 1568, addon = 2, achievement = "Friendly Fire", orangeText = "scripts.usable_outfit_items.firefighter_flame" },
}

local usableOutfitItems = Action()

function usableOutfitItems.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not player:isPremium() then
		player:sendCancelMessage(RETURNVALUE_YOUNEEDPREMIUMACCOUNT)
		return true
	end

	local outfitInfo = outfitConfig[item.itemid]
	local looktype = player:getSex() == PLAYERSEX_FEMALE and outfitInfo.female or outfitInfo.male
	if not player:hasOutfit(looktype) then
		if outfitInfo.addon then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "actions.outfit_items.msg_need_outfit")
			return true
		end

		player:addOutfit(outfitInfo.female)
		player:addOutfit(outfitInfo.male)
		player:getPosition():sendMagicEffect(outfitInfo.effect or CONST_ME_GIFT_WRAPS)
		if outfitInfo.orangeText then
			player:sayLocalized(outfitInfo.orangeText, TALKTYPE_MONSTER_SAY)
		elseif outfitInfo.whiteText then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, outfitInfo.whiteText)
		end
		item:remove(1)
		return true
	end

	if player:hasOutfit(looktype, outfitInfo.addon) then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "actions.outfit_items.msg_already_own")
		return true
	end

	player:addOutfitAddon(outfitInfo.female, outfitInfo.addon)
	player:addOutfitAddon(outfitInfo.male, outfitInfo.addon)
	player:getPosition():sendMagicEffect(outfitInfo.effect or CONST_ME_GIFT_WRAPS)
	if outfitInfo.orangeText then
		player:sayLocalized(outfitInfo.orangeText, TALKTYPE_MONSTER_SAY)
	elseif outfitInfo.whiteText then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, outfitInfo.whiteText)
	end

	if player:hasOutfit(looktype, 3) then
		player:addAchievement(outfitInfo.achievement)
	end

	item:remove(1)
	return true
end

for itemId, _ in pairs(outfitConfig) do
	usableOutfitItems:id(itemId)
end

usableOutfitItems:register()
