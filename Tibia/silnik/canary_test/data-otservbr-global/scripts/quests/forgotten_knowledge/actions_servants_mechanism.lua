local config = {
	[26663] = { storage = Storage.Quest.U11_02.ForgottenKnowledge.MechanismDiamond, counter = Storage.Quest.U11_02.ForgottenKnowledge.DiamondServant, msg = "quests.forgotten_knowledge.diamond_entities" },
	[26664] = { storage = Storage.Quest.U11_02.ForgottenKnowledge.MechanismGolden, counter = Storage.Quest.U11_02.ForgottenKnowledge.GoldenServant, msg = "quests.forgotten_knowledge.golden_entities" },
}

local function clearGolems()
	local specs, spec = Game.getSpectators(Position(32815, 32874, 13), false, false, 63, 63, 63, 63)
	for i = 1, #specs do
		spec = specs[i]
		if Game.getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.MechanismDiamond) < 1 then
			if spec:isMonster() and spec:getName():lower() == "diamond servant replica" then
				spec:getPosition():sendMagicEffect(CONST_ME_POFF)
				spec:remove()
			end
		end
		if Game.getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.MechanismGolden) < 1 then
			if spec:isMonster() and spec:getName():lower() == "golden servant replica" then
				spec:getPosition():sendMagicEffect(CONST_ME_POFF)
				spec:remove()
			end
		end
		if spec:isMonster() and spec:getName():lower() == "iron servant replica" then
			if math.random(100) <= 40 then
				spec:getPosition():sendMagicEffect(CONST_ME_POFF)
				spec:remove()
			end
		end
	end
end

local function turnOff(storage, counter)
	Game.setStorageValue(storage, 0)
	Game.setStorageValue(counter, 0)
	clearGolems()
	local teleport = Tile(Position(32815, 32870, 13)):getItemById(10840)
	if teleport then
		teleport:getPosition():sendMagicEffect(CONST_ME_POFF)
		teleport:remove()
	end
end

local forgottenKnowledgeMechanism = Action()
function forgottenKnowledgeMechanism.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local lever = config[item.actionid]
	if item.itemid == 9125 then
		if Game.getStorageValue(lever.storage) >= 1 then
			player:sayLocalized("quests.actions_servants_mechanism.say_2", TALKTYPE_MONSTER_SAY, false, nil, toPosition)
			return true
		end
		clearGolems()
		Game.setStorageValue(lever.storage, 1)
		Game.setStorageValue(lever.counter, 0)
		addEvent(turnOff, 10 * 60 * 1000, lever.storage, lever.counter)
		item:transform(9126)
		player:sayLocalized("quests.actions_servants_mechanism.say_1", TALKTYPE_MONSTER_SAY, false, nil, toPosition)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, lever.msg)
	elseif item.itemid == 9126 then
		item:transform(9125)
	end
	return true
end

for actionId, info in pairs(config) do
	forgottenKnowledgeMechanism:aid(actionId)
end

forgottenKnowledgeMechanism:register()
