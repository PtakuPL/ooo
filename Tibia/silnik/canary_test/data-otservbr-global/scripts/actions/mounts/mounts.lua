local ACTION_RUN, ACTION_BREAK, ACTION_NONE, ACTION_ALL = 1, 2, 3, 4
local TYPE_MONSTER, TYPE_NPC, TYPE_ITEM, TYPE_ACTION, TYPE_UNIQUE = 1, 2, 3, 4, 5

local config = {
	[5907] = { NAME = "Bear", ID = 3, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 20, FAIL_MSG = { { 1, "scripts.mounts.fail_1" }, { 2, "scripts.mounts.fail_2" }, { 3, "scripts.mounts.fail_3" } }, SUCCESS_MSG = "scripts.mounts.success_1", ACHIEV = "Bearbaiting" },
	[12308] = { NAME = "Black Sheep", ID = 4, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 25, FAIL_MSG = { { 1, "scripts.mounts.fail_4" }, { 2, "scripts.mounts.fail_5" }, { 3, "scripts.mounts.fail_6" } }, SUCCESS_MSG = "scripts.mounts.success_2", ACHIEV = "Little Ball of Wool" },
	[12260] = { NAME = "Boar", ID = 10, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_7" }, { 3, "scripts.mounts.fail_8" } }, SUCCESS_MSG = "scripts.mounts.success_3", ACHIEV = "Pig-Headed" },
	[12318] = { NAME = "Crustacea Gigantica", ID = 7, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_9" }, { 2, "scripts.mounts.fail_10" } }, SUCCESS_MSG = "scripts.mounts.success_4", ACHIEV = "Fried Shrimp" },
	[12547] = { NAME = "Crystal Wolf", ID = 16, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_11" } }, SUCCESS_MSG = "scripts.mounts.success_5", ACHIEV = "The Right Tone" },
	[12548] = { NAME = "Donkey", ID = 13, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_12" }, { 2, "scripts.mounts.fail_13" }, { 3, "scripts.mounts.fail_14" } }, SUCCESS_MSG = "scripts.mounts.success_6", ACHIEV = "Loyal Lad" },
	[16155] = { NAME = "Dragonling", ID = 31, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 1, "scripts.mounts.fail_15" }, { 2, "scripts.mounts.fail_16" } }, SUCCESS_MSG = "scripts.mounts.success_7", ACHIEV = "Dragon Mimicry" },
	[12307] = { NAME = "Draptor", ID = 6, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_17" }, { 3, "scripts.mounts.fail_18" } }, SUCCESS_MSG = "scripts.mounts.success_8", ACHIEV = "Scales and Tail" },
	[12546] = { NAME = "Dromedary", ID = 20, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_19" } }, SUCCESS_MSG = "scripts.mounts.success_9", ACHIEV = "Fata Morgana" },
	[12550] = { NAME = "Enraged White Deer", ID = 18, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 2, "scripts.mounts.fail_20" }, { 3, "scripts.mounts.fail_21" } }, SUCCESS_MSG = "scripts.mounts.success_10", ACHIEV = "Friend of Elves" },
	[28791] = { NAME = "Flying Book", ID = 126, BREAK = false, TYPE = TYPE_MONSTER, CHANCE = 20, FAIL_MSG = { { 1, "scripts.mounts.fail_22" } }, SUCCESS_MSG = "scripts.mounts.success_11", ACHIEV = "Bibliomaniac" },
	[19136] = { NAME = "Gravedigger", ID = 39, BREAK = false, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_23" }, { 3, "scripts.mounts.fail_24" } }, SUCCESS_MSG = "scripts.mounts.success_12", ACHIEV = "Blacknailed" },
	[31576] = { NAME = "Gryphon", ID = 144, BREAK = false, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 1, "scripts.mounts.fail_25" } }, SUCCESS_MSG = "scripts.mounts.success_13", ACHIEV = "Gryphon Rider" },
	[30171] = { NAME = "Hibernal Moth", ID = 131, BREAK = false, TYPE = TYPE_MONSTER, CHANCE = 20, FAIL_MSG = { { 2, "scripts.mounts.fail_26" }, { 4, "scripts.mounts.fail_27" } }, SUCCESS_MSG = "scripts.mounts.success_14", ACHIEV = "Moth Whisperer" },
	[12305] = { NAME = "inoperative tin lizzard", ID = 8, BREAK = true, TYPE = TYPE_ITEM, CHANCE = 40, FAIL_MSG = { { 2, "scripts.mounts.fail_28" } }, SUCCESS_MSG = "scripts.mounts.success_15", ACHIEV = "Knock on Wood" },
	[12801] = { NAME = "inoperative uniwheel", ID = 15, BREAK = true, TYPE = TYPE_ITEM, CHANCE = 40, FAIL_MSG = { { 3, "scripts.mounts.fail_29" }, { 2, "scripts.mounts.fail_30" } }, SUCCESS_MSG = "scripts.mounts.success_16", ACHIEV = "Stuntman" },
	[16153] = { NAME = "Ironblight", ID = 29, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 1, "scripts.mounts.fail_31" }, { 2, "scripts.mounts.fail_32" }, { 3, "scripts.mounts.fail_33" } }, SUCCESS_MSG = "scripts.mounts.success_17", ACHIEV = "Magnetised" },
	[30170] = { NAME = "Lacewing Moth", ID = 130, BREAK = false, TYPE = TYPE_MONSTER, CHANCE = 20, FAIL_MSG = { { 2, "scripts.mounts.fail_34" }, { 4, "scripts.mounts.fail_35" } }, SUCCESS_MSG = "scripts.mounts.success_18", ACHIEV = "Lacewing Catcher" },
	[14143] = { NAME = "Ladybug", ID = 27, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 1, "scripts.mounts.fail_36" }, { 3, "scripts.mounts.fail_37" } }, SUCCESS_MSG = "scripts.mounts.success_19", ACHIEV = "Lovely Dots" },
	[16154] = {
		NAME = "Magma Crawler",
		ID = 30,
		BREAK = true,
		TYPE = TYPE_MONSTER,
		CHANCE = 30,
		FAIL_MSG = { { 1, "scripts.mounts.fail_38" }, { 2, "scripts.mounts.fail_39" }, { 3, "scripts.mounts.fail_40" } },
		SUCCESS_MSG = "scripts.mounts.success_20",
		ACHIEV = "Way to Hell",
	},
	[14142] = { NAME = "Manta Ray", ID = 28, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 1, "scripts.mounts.fail_41" }, { 3, "scripts.mounts.fail_42" } }, SUCCESS_MSG = "scripts.mounts.success_21", ACHIEV = "Beneath the Sea" },
	[12306] = { NAME = "Midnight Panther", ID = 5, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 20, FAIL_MSG = { { 1, "scripts.mounts.fail_43" }, { 2, "scripts.mounts.fail_44" } }, SUCCESS_MSG = "scripts.mounts.success_22", ACHIEV = "Starless Night" },
	[16251] = { NAME = "Modified Gnarlhound", ID = 32, BREAK = false, TYPE = TYPE_MONSTER, CHANCE = 100, FAIL_MSG = {}, SUCCESS_MSG = "scripts.mounts.success_23", ACHIEV = "Mind the Dog!" },
	[27605] = { NAME = "Mole", ID = 119, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 2, "scripts.mounts.fail_45" }, { 4, "scripts.mounts.fail_46" } }, SUCCESS_MSG = "scripts.mounts.success_24", ACHIEV = "Up the Molehill" },
	[21439] = { NAME = "Noble Lion", ID = 40, BREAK = false, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 2, "scripts.mounts.fail_47" }, { 4, "scripts.mounts.fail_48" } }, SUCCESS_MSG = "scripts.mounts.success_25", ACHIEV = "Lion King" },
	[12549] = { NAME = "Panda", ID = 19, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 4, "scripts.mounts.fail_49" } }, SUCCESS_MSG = "scripts.mounts.success_26", ACHIEV = "Chequered Teddy" },
	[12509] = { NAME = "Sandstone Scorpion", ID = 21, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_50" }, { 2, "scripts.mounts.fail_51" } }, SUCCESS_MSG = "scripts.mounts.success_27", ACHIEV = "Golden Sands" },
	[20274] = { NAME = "Shock Head", ID = 42, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 1, "scripts.mounts.fail_52" }, { 3, "scripts.mounts.fail_53" } }, SUCCESS_MSG = "scripts.mounts.success_28", ACHIEV = "Personal Nightmare" },
	[24960] = { NAME = "Stone Rhino", ID = 106, BREAK = false, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 1, "scripts.mounts.fail_54" }, { 3, "scripts.mounts.fail_55" } }, SUCCESS_MSG = "scripts.mounts.success_29", ACHIEV = "Rhino Rider" },
	[12519] = { NAME = "Slug", ID = 14, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_56" }, { 3, "scripts.mounts.fail_57" } }, SUCCESS_MSG = "scripts.mounts.success_30", ACHIEV = "Slugging Around" },
	[12311] = { NAME = "Terror Bird", ID = 2, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 15, FAIL_MSG = { { 1, "scripts.mounts.fail_58" }, { 3, "scripts.mounts.fail_59" } }, SUCCESS_MSG = "scripts.mounts.success_31", ACHIEV = "Pecking Order" },
	[12304] = { NAME = "Undead Cavebear", ID = 12, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_60" } }, SUCCESS_MSG = "scripts.mounts.success_32", ACHIEV = "Out of the Stone Age" },
	[12320] = { NAME = "Wailing Widow", ID = 1, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 40, FAIL_MSG = { { 1, "scripts.mounts.fail_61" }, { 2, "scripts.mounts.fail_62" } }, SUCCESS_MSG = "scripts.mounts.success_33", ACHIEV = "Spin-Off" },
	[21186] = { NAME = "Walker", ID = 43, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 2, "scripts.mounts.fail_63" }, { 4, "scripts.mounts.fail_64" } }, SUCCESS_MSG = "scripts.mounts.success_34", ACHIEV = "Gear Up" },
	[17858] = { NAME = "Water Buffalo", ID = 35, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 30, FAIL_MSG = { { 1, "scripts.mounts.fail_65" }, { 3, "scripts.mounts.fail_66" } }, SUCCESS_MSG = "scripts.mounts.success_35", ACHIEV = "Swamp Beast" },
	[12802] = { NAME = "Wild Horse", ID = 17, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 15, FAIL_MSG = { { 1, "scripts.mounts.fail_67" }, { 2, "scripts.mounts.fail_68" } }, SUCCESS_MSG = "scripts.mounts.success_36", ACHIEV = "Lucky Horseshoe" },
	[34258] = { NAME = "White Lion", ID = 174, BREAK = true, TYPE = TYPE_MONSTER, CHANCE = 50, FAIL_MSG = { { 1, "scripts.mounts.fail_69" }, { 2, "scripts.mounts.fail_70" } }, SUCCESS_MSG = "scripts.mounts.success_37", ACHIEV = "Well Roared, Lion!" },
}

local function doFailAction(cid, mount, pos, item, itemEx, loseItem)
	local action, effect = mount.FAIL_MSG[math.random(#mount.FAIL_MSG)], CONST_ME_POFF
	if action[1] == ACTION_RUN then
		Creature(itemEx.uid):remove()
	elseif action[1] == ACTION_BREAK then
		effect = CONST_ME_BLOCKHIT
		if loseItem then
			Item(item.uid):remove(1)
		end
	elseif action[1] == ACTION_ALL then
		Creature(itemEx.uid):remove()
		if loseItem then
			Item(item.uid):remove(1)
		end
	end

	pos:sendMagicEffect(effect)
	Player(cid):sayLocalized(action[2], TALKTYPE_MONSTER_SAY)
	return action
end

local mounts = Action()

function mounts.onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	local targetMonster = Monster(itemEx.uid)
	local targetNpc = Npc(itemEx.uid)
	local targetItem = Item(itemEx.uid)
	local mount = config[item.itemid]
	if mount == nil or player:hasMount(mount.ID) then
		return false
	end

	local rand = math.random(100)
	--Monster Mount
	if targetMonster ~= nil and mount.TYPE == TYPE_MONSTER then
		if Creature(itemEx.uid):getMaster() then
			player:sayLocalized("scripts.mounts.say_1", TALKTYPE_MONSTER_SAY)
			return true
		end

		if mount.NAME == targetMonster:getName() then
			if rand > mount.CHANCE then
				doFailAction(cid, mount, toPosition, item, itemEx, mount.BREAK)
				return true
			end
			if mount.ACHIEV then
				player:addAchievement(mount.ACHIEV)
			end
			player:addAchievement("Natural Born Cowboy")
			player:addMount(mount.ID)
			player:sayLocalized(mount.SUCCESS_MSG, TALKTYPE_MONSTER_SAY)
			targetMonster:remove()
			toPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
			Item(item.uid):remove(1)
			return true
		elseif item.itemid == 12548 and targetMonster:getOutfit().lookType == 387 then
			if rand > mount.CHANCE then
				doFailAction(cid, mount, toPosition, item, itemEx, mount.BREAK)
				return true
			end
			if mount.ACHIEV then
				player:addAchievement(mount.ACHIEV)
			end
			player:addAchievement("Natural Born Cowboy")
			player:addMount(mount.ID)
			player:sayLocalized(mount.SUCCESS_MSG, TALKTYPE_MONSTER_SAY)
			targetMonster:remove()
			toPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
			Item(item.uid):remove(1)
			return true
		end
		--NPC Mount
	elseif targetNpc ~= nil and mount.TYPE == TYPE_NPC then
		if mount.NAME == targetNpc:getName() then
			if rand > mount.CHANCE then
				doFailAction(cid, mount, toPosition, item, itemEx, mount.BREAK)
				return true
			end
			if mount.ACHIEV then
				player:addAchievement(mount.ACHIEV)
			end
			player:addAchievement("Natural Born Cowboy")
			player:addMount(mount.ID)
			player:sayLocalized(mount.SUCCESS_MSG, TALKTYPE_MONSTER_SAY)
			toPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
			Item(item.uid):remove(1)
			return true
		end
		--Item Mount
	elseif targetItem ~= nil and mount.TYPE == TYPE_ITEM then
		if mount.NAME == targetItem:getName() then
			if rand > mount.CHANCE then
				doFailAction(cid, mount, toPosition, item, itemEx, mount.BREAK)
				return true
			end
			if mount.ACHIEV then
				player:addAchievement(mount.ACHIEV)
			end
			player:addAchievement("Natural Born Cowboy")
			player:addMount(mount.ID)
			player:sayLocalized(mount.SUCCESS_MSG, TALKTYPE_MONSTER_SAY)
			toPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
			Item(item.uid):remove(1)
			return true
		end
		--Action Mount
	elseif itemEx.actionid > 0 and mount.TYPE == TYPE_ACTION then
		if mount.NAME == itemEx.actionid then
			if rand > mount.CHANCE then
				doFailAction(cid, mount, toPosition, item, itemEx, mount.BREAK)
				return true
			end
			if mount.ACHIEV then
				player:addAchievement(mount.ACHIEV)
			end
			player:addAchievement("Natural Born Cowboy")
			player:addMount(mount.ID)
			player:sayLocalized(mount.SUCCESS_MSG, TALKTYPE_MONSTER_SAY)
			toPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
			Item(item.uid):remove(1)
			return true
		end
		--Unique Mount
	elseif itemEx.uid <= 65535 and mount.TYPE == TYPE_UNIQUE then
		if mount.NAME == itemEx.uid then
			if rand > mount.CHANCE then
				doFailAction(cid, mount, toPosition, item, itemEx, mount.BREAK)
				return true
			end
			if mount.ACHIEV then
				player:addAchievement(mount.ACHIEV)
			end
			player:addAchievement("Natural Born Cowboy")
			player:addMount(mount.ID)
			player:sayLocalized(mount.SUCCESS_MSG, TALKTYPE_MONSTER_SAY)
			toPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
			Item(item.uid):remove(1)
			return true
		end
	end
	return false
end

for index, value in pairs(config) do
	mounts:id(index)
end

mounts:register()
