local config = {
	[768] = {
		[1] = { female = 269, male = 268, msg = "nightmare" },
		[2] = { female = 279, male = 278, msg = "brotherhood" },
	},
	[769] = {
		[1] = { female = 269, male = 268, addon = 1, msg = "first nightmare" },
		[2] = { female = 279, male = 278, addon = 1, msg = "first brotherhood" },
		storageValue = 2,
	},
	[770] = {
		[1] = { female = 269, male = 268, addon = 2, msg = "second nightmare" },
		[2] = { female = 279, male = 278, addon = 2, msg = "second brotherhood" },
		storageValue = 3,
	},
}

local dreamerDocuments = Action()
function dreamerDocuments.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local useItem = config[item.itemid]
	if not useItem then
		return true
	end

	local choice = useItem[1]
	if player:getStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits) > player:getStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits) then
		choice = useItem[2]
	end

	if choice.addon then
		if player:hasOutfit(player:getSex() == PLAYERSEX_FEMALE and choice.female or choice.male) then
			if not player:hasOutfit(player:getSex() == PLAYERSEX_FEMALE and choice.female or choice.male, choice.addon) then
				if player:getStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits) >= useItem.storageValue or player:getStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits) >= useItem.storageValue then
					player:addOutfitAddon(choice.female, choice.addon)
					player:addOutfitAddon(choice.male, choice.addon)
					player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_documents.msg_1" .. choice.msg .. " addon!")
					player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
					item:remove(1)
				else
					return false
				end
			else
				player:sendLocalizedCancelMessage("quests.dreamers_challenge_quest.you_have_already_obtained_this_addon")
			end
		else
			return false
		end
	else
		if not player:hasOutfit(player:getSex() == PLAYERSEX_FEMALE and choice.female or choice.male) then
			if player:getStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits) >= 1 or player:getStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits) >= 1 then
				player:addOutfit(choice.female)
				player:addOutfit(choice.male)
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_documents.msg_2" .. choice.msg .. " outfit!")
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
				item:remove(1)
			else
				return false
			end
		else
			player:sendLocalizedCancelMessage("quests.adventures_of_galthen.you_have_already_obtained_this_outfit")
		end
	end
	return true
end

dreamerDocuments:id(768, 769, 770)
dreamerDocuments:register()
