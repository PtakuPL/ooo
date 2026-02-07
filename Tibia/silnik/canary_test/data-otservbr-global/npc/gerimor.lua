local internalNpcName = "Gerimor"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 144,
	lookHead = 60,
	lookBody = 22,
	lookLegs = 24,
	lookFeet = 32,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

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

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gerimor.greet_msg_1")
	end

	return true
end

-- Keywords
keywordHandler:addKeyword({ "place" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_1",
})

keywordHandler:addKeyword({ "me" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"I'm a member of a circle of persons, that joined wisdom and resources for a common purpose. Let's say, we have an eye on the greater picture in the matters of our world. ...",
		"We are watching and evaluating what is happening in our world.	Trying to avert the worst and offering a helping hand where we deem it needed. ...",
		"We usually avoid to interfere directly in the affairs of the world and vain politics are not our concern at all.",
	},
})

keywordHandler:addKeyword({ "circle" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_2",
})

keywordHandler:addKeyword({ "persons" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Well, while I focus more on the matters of life, some of my peers have different approaches and emphasize other aspects of the world more in their observations. ...",
		"Regardless we share a common goal of balance and harmony.",
	},
})

keywordHandler:addKeyword({ "approaches" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_3",
})

keywordHandler:addKeyword({ "dawn" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Even we know the individual that was somewhat of our funder, only as the wise man. ...",
		"He was the first to bring bright and dedicated minds together, to bring at least a little order and guidance into troubled and chaotic times. ...",
		"The order predates mankind and never bothered to give itself a name. Such assumptions of pretence and vanity have no place in our mindset.",
	},
})

keywordHandler:addKeyword({ "guidance" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Most times we are silent watchers and keeper of knowledge that share what they have learned with each other. We are more concerned about knowledge and wisdom and power means little to us. ...",
		"To solve problems we usually try to convince the right people to do the right thing. We usually even lack the means for a more direct interference.",
	},
})

keywordHandler:addKeyword({ "direct" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Sometimes it's necessary to do something about a situation that became threatening to the world itself. ...",
		"It is gladly a rare occurrence and usually it is sufficient to somewhat offer a guiding hand to avert a course that would lead to more dire consequences. Nonetheless sometimes we have to interfere.",
	},
})

keywordHandler:addKeyword({ "interfere" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_4",
})

keywordHandler:addKeyword({ "feyrist" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_5",
})

keywordHandler:addKeyword({ "fae" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The fae vary greatly in size and appearance. There are different kinds of fae like fauns, pixies, pookas, swan maidens, nymphs and boogies. Those mystical creatures are wielding power in magic and elementals. ...",
		"Most of them are rather reclusive and live peaceful lives in their secret realm. Sometimes they are called the 'children of dreams' or 'the dream born' because the fae are born from the mortals' dreams.",
	},
})

keywordHandler:addKeyword({ "fauns" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Fauns are half-human, half-beast nature spirits inhabiting the woods and mountains of Feyrist. They are a slightly roguish but cheerful folk, lovers of wine and dancing. ...",
		"Fauns show a youthful and graceful aspect but they are also brave and fearless when it comes to defend themselves. As Maelyrra told me, they emerge from mortals' dreams about celebrations, music and dancing. ...",
		"Lately, some fauns on Feyrist are tainted by the mysterious, sinister force that is threatening Feyrist as well as the rest of Tibia.",
	},
})

keywordHandler:addKeyword({ "pixies" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Pixies are small nature spirits and mythical creatures inhabiting the forests and plains of Feyrist. They are generally benign, but at times, they may also display mischievous traits. ...",
		"Like most of the fae, pixies love dancing and are often gathering in larger groups to dance on secluded glades. Pixies love flowers, butterflies, shimmering beetles, gems and other colourful things. ...",
		"They also love the taste of honey, sweetened oat and ripe grapes. As Maelyrra told me, pixies emerge from mortals' dreams about friends and family.",
	},
})

keywordHandler:addKeyword({ "pookas" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Pookas are nature spirits in animal form, looking like big hares with a faintly glittering fur. They are benign but mischievous, for sure with good reason regarded as the tricksters among the fae. ...",
		"Pookas love to play pranks on others, snitching and hiding things or telling made-up stories. They are capricious and fickle creatures. Pookas emerge from mortals' dreams about gems, treasures and gold. ...",
		"Lately, some pookas on Feyrist are tainted by a mysterious, sinister force that is threatening Feyrist as well as the rest of Tibia.",
	},
})

keywordHandler:addKeyword({ "swan maidens" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Swan maidens are fae who can shapeshift from human form to swan form. The magical item allowing this transformation is a swan feather cloak, a garment with swan feathers attached. ...",
		"Here on Feyrist it is always hard to tell whether a swan swimming on a lake is an ordinary animal or a swan maiden in her bird shape. ...",
		"They protect the wilds of their secret realm from every intruder and live in small flocks along secluded lakeshores. As Maelyrra told me, swan maidens emerge from mortals' dreams about flying.",
	},
})

keywordHandler:addKeyword({ "nymphs" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Nymphs are female nature spirits and usually take the form of beautiful, young maidens who love to dance and sing. They dwell in the hills and forests of Feyrist, often near lakes and streams and they can't die of old age nor illness. ...",
		"They have a special, strong bond to the plants and animals of their domain and are very protective of Feyrist's flora and fauna. As Maelyrra told me, nymphs emerge from mortals' dreams about love.",
	},
})

keywordHandler:addKeyword({ "boogies" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Boogies are a rather twisted kind of fae. Other than pixies, nymphs or fauns they favour underground caves and tunnels over forests or lush meadows. ...",
		"Only at night, they are roaming the surface, chasing other fae and visitors to Feyrist alike. They were once clumsy yet peaceful fae, but they are now twisted and tainted by a mysterious, sinister force.",
	},
})

keywordHandler:addKeyword({ "maelyrra" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"She's the queen of a fae court. You can find her on a glade in the deep forest. It was queen Maelyrra who granted me permission to stay here in Feyrist. ...",
		"I promised to inform her about anything I find out about the abominable force that threatens this world.",
	},
})

keywordHandler:addKeyword({ "fae court" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The fae vary greatly in size and appearance. There are different kinds of fae like fauns, pixies, pookas, swan maidens, nymphs and boogies. Those mystical creatures are wielding power in magic and elementals. ...",
		"Most of them are rather reclusive and live peaceful lives in their secret realm. Sometimes they are called the ,children of dreams' or ,the dream born' because the fae are born from the mortals' dreams.",
	},
})

keywordHandler:addKeyword({ "cults" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"It doesn't seem that the cults share a common theme or object of reverence but there has to be some connection beyond being at the centre of culminations of disruptive power from beyond. ...",
		"The connection is of second thought though. Connected or not, they further the death of our world. That alone makes it imperative to dig those cults out and destroy their cores. ...",
		"We won't be able to rout our each and any movement but if we manage to neutralize the worst, we gain some time and deny the enemy much of its leverage on the future of our world.",
	},
})

keywordHandler:addKeyword({ "worst" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"We have located some of the worst culminations of otherworldly presence and our sources returned information about them with different results of success. ...",
		"Some information I can provide you will be rather sparse and much is left to speculation but you should have at least some lead where to go and investigate.",
	},
})

keywordHandler:addKeyword({ "investigate" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_6",
})
keywordHandler:addKeyword({ "actions" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_7",
})
keywordHandler:addKeyword({ "fabric" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_8",
})

keywordHandler:addKeyword({ "works" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"We haven't completely figured out what our enemy exactly is. For one, this thing defies all laws of nature and comprehension, ...",
		"that understanding it is either impossible or twist a mind in ways that are not meant to be. Also the Yalahari who figured out way too much about the thing, became tainted and changed by this knowledge ...",
		"And ultimately not only fell and became his, they also provided the thing with something of their own, be it knowledge, understanding or even direction, purpose. ...",
		"In some way their tainted knowledge brought the unthinkable into a resemblance of existence. ...",
		"That is why we cant dabble too much in figuring this out and rather concentrate on our fight to severe its ties to our world.",
	},
})

keywordHandler:addKeyword({ "ties" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_9",
})

local config = {
	missions = {
		["minotaurs"] = {
			textKey = {
				"npc.gerimor.minotaurs_text_1",
				"npc.gerimor.minotaurs_text_2",
			},
			completeTextKey = {
				"npc.gerimor.minotaurs_complete_1",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Minotaurs.Mission,
			value = 5,
			rewardExp = 25000,
		},
		["prosperity"] = {
			textKey = {
				"npc.gerimor.prosperity_text_1",
				"npc.gerimor.prosperity_text_2",
			},
			completeTextKey = {
				"npc.gerimor.prosperity_complete_1",
				"npc.gerimor.prosperity_complete_2",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.MotA.Mission,
			value = 14,
			rewardExp = 50000,
		},
		["barkless"] = {
			textKey = {
				"npc.gerimor.barkless_text_1",
				"npc.gerimor.barkless_text_2",
			},
			completeTextKey = {
				"npc.gerimor.barkless_complete_1",
				"npc.gerimor.barkless_complete_2",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Barkless.Mission,
			value = 6,
			rewardExp = 50000,
		},
		["orcs"] = {
			textKey = {
				"npc.gerimor.orcs_text_1",
			},
			completeTextKey = {
				"npc.gerimor.orcs_complete_1",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Orcs.Mission,
			value = 2,
			rewardExp = 25000,
		},
		["life"] = {
			textKey = {
				"npc.gerimor.life_text_1",
			},
			completeTextKey = {
				"npc.gerimor.life_complete_1",
				"npc.gerimor.life_complete_2",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Life.Mission,
			value = 9,
			rewardExp = 50000,
		},
		["misguided"] = {
			textKey = {
				"npc.gerimor.misguided_text_1",
				"npc.gerimor.misguided_text_2",
			},
			completeTextKey = {
				"npc.gerimor.misguided_complete_1",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Misguided.Mission,
			value = 4,
			rewardExp = 50000,
		},
		["humans"] = {
			textKey = {
				"npc.gerimor.humans_text_1",
				"npc.gerimor.humans_text_2",
			},
			completeTextKey = {
				"npc.gerimor.humans_complete_1",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Humans.Mission,
			value = 2,
			rewardExp = 25000,
		},
	},
}

local storage = {}
local value = {}
local rewardExperience = {}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "missions") then
		if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission) > 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_1")
			npcHandler:setTopic(playerId, 0)
		elseif
			player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Minotaurs.Mission) == 6
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) == 10
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 15
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.Mission) == 7
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Misguided.Mission) == 5
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Orcs.Mission) == 3
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Humans.Mission) == 3
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission) < 2
		then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_6")
			npcHandler:setTopic(playerId, 0)
			if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission) < 1 then
				player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission, 1)
				player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.AccessDoor, 1)
			end
		elseif player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_3")
			npcHandler:setTopic(playerId, 4)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		local missionsTable = config.missions[message:lower()]
		if missionsTable then
			storage[playerId] = missionsTable.storage
			value[playerId] = missionsTable.value
			rewardExperience[playerId] = missionsTable.rewardExp
			if player:getStorageValue(storage[playerId]) > 0 and player:getStorageValue(storage[playerId]) == value[playerId] then
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, missionsTable.completeTextKey, 4000)
				player:setStorageValue(storage[playerId], player:getStorageValue(storage[playerId]) + 1)
				player:addExperience(rewardExperience[playerId])
				player:sendLocalizedTextMessage(MESSAGE_EXPERIENCE, "npc.gerimor.gained_experience", {rewardExperience[playerId]})
				npcHandler:setTopic(playerId, 0)
			elseif player:getStorageValue(storage[playerId]) > 0 and player:getStorageValue(storage[playerId]) > value[playerId] then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_2")
				npcHandler:setTopic(playerId, 2)
			else
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, missionsTable.textKey, 4000)
				npcHandler:setTopic(playerId, 3)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 3 then
			if player:getStorageValue(storage[playerId]) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_3")
				player:setStorageValue(storage[playerId], 1)
				if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Questline) < 1 then
					player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Questline, 1)
				end
				npcHandler:setTopic(playerId, 2)
			elseif player:getStorageValue(storage[playerId]) > 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_4")
				npcHandler:setTopic(playerId, 2)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			local vocationRewards = {
				[VOCATION.BASE_ID.SORCERER] = { itemId = 26190, itemName = "reflecting crown" },
				[VOCATION.BASE_ID.DRUID] = { itemId = 26187, itemName = "leaf crown" },
				[VOCATION.BASE_ID.PALADIN] = { itemId = 26189, itemName = "incandescent crown" },
				[VOCATION.BASE_ID.KNIGHT] = { itemId = 26188, itemName = "iron crown" },
			}
			local vocationId = player:getVocation():getBaseId()
			local reward = vocationRewards[vocationId]
			local item = ""
			if reward then
				player:addItem(reward.itemId)
				item = reward.itemName
			end
			player:addExperience(50000)
			player:addItem(26186)
			player:addAchievement("Corruption Contained")
			player:sendLocalizedTextMessage(MESSAGE_EXPERIENCE, "system.experience.gained", {"50000"})
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "system.item.received", {"mystery box"})
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "npc.gerimor.gained_item", {item})
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission, 3)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_6")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.gerimor.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
