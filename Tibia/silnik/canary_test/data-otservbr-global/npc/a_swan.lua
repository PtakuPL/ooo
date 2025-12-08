local internalNpcName = "A Swan"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookTypeEx = 25445,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local npcI18n = NPC_LIB and NPC_LIB.i18n
local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 11 then
			saySequence(npc, creature, {
				"npc.a_swan.mission_intro.1",
				"npc.a_swan.mission_intro.2",
				"npc.a_swan.mission_intro.3",
				"npc.a_swan.mission_intro.4",
			}, {
				"My sister Ikassis sent you? Blessed be her soul! Yes, it is true: I need help. Listen, I will tell you a secret but please don't break it. As you might already suspect I'm not really a swan but a fae. ...",
				"But other than many of my siblings I did not take over a swan's body. I'm a swan maiden and this is one of my two aspects. I can take the shape of a swan as well as that of a young maiden. ...",
				"But to do so I need a magical artefact: a cloak made of swan feathers. If I lose this cloak - or someone steals it from me - I'm stuck to the form of a swan and can't change shape anymore. And this is exactly what happened: ...",
				"A troll stalked me while I was bathing in the river and he stole my cloak. Now I am trapped in the form of a swan. Please, can you find the thief and bring back the cloak?",
			})
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(ThreatenedDreams.Mission01[1]) == 14 then
			if player:getItemCount(25244) >= 5 then
				player:removeItem(25244, 5)
				player:setStorageValue(ThreatenedDreams.Mission01[1], 15)
				saySequence(npc, creature, {
					"npc.a_swan.mission_recover.1",
					"npc.a_swan.mission_recover.2",
				}, {
					"This is everything that remained of my cloak? That's terrible! However, I guess I can put the feathers together again. Yes, that should be enough feathers. ...",
					"Please give them to me so I can restore my cloak. But don't watch me! Swan maidens don't like to be observed. Nature's blessings, human being. I will tell Ikassis that you have been of great assistance.",
				})
				npcHandler:setTopic(playerId, 0)
			else
				sayLine(player, npc, creature, "npc.a_swan.need_feathers", "You need to deliver me like 5 feathers.")
			end
		else
			sayLine(player, npc, creature, "npc.a_swan.not_on_mission", "You are not on that mission.")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			saySequence(npc, creature, {
				"npc.a_swan.mission_accept.1",
				"npc.a_swan.mission_accept.2",
			}, {
				"Thank you, human being! I guess the thieving troll headed to the mountains east of here. As far as I know you can only reach these mountain tops by diving into a small cave. ...",
				"The connecting tunnels will lead you to a mountain where you may discover him. I heard a man named Jerom talking about this when he passed by this river. Perhaps he knows more about it.",
			})
			player:setStorageValue(ThreatenedDreams.Mission01[1], 12)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

local function saySequence(npc, creature, keys, fallback)
	if npcI18n then
		return npcI18n.npcSayMultiple(npcHandler, npc, creature, keys, 800)
	end
	npcHandler:say(fallback, npc, creature)
	return true
end

local function sayLine(player, npc, creature, key, fallback)
	if npcI18n then
		return npcI18n.sayLocalized(player, key)
	end
	npcHandler:say(fallback, npc, creature)
	return true
end

if npcI18n and npcHandler.setLocalizedMessage then
	npcI18n.setLocalizedGreet(npcHandler, "npc.a_swan.greet")
else
	npcHandler:setMessage(MESSAGE_GREET, "I salute you, mortal being.")
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
