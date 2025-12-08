local internalNpcName = "Flickering Soul"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookType = 1219,
	lookHead = 6,
	lookBody = 26,
	lookLegs = 26,
	lookFeet = 6,
	lookAddons = 0,
	lookMount = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, player)
	npcHandler:onAppear(npc, player)
end

npcType.onDisappear = function(npc, player)
	npcHandler:onDisappear(npc, player)
end

npcType.onMove = function(npc, player, fromPosition, toPosition)
	npcHandler:onMove(npc, player, fromPosition, toPosition)
end

npcType.onSay = function(npc, player, type, message)
	npcHandler:onSay(npc, player, type, message)
end

npcType.onCloseChannel = function(npc, player)
	npcHandler:onCloseChannel(npc, player)
end

local function playerSayCallback(npc, player, type, message)
	if not npcHandler:checkInteraction(npc, player) then
		return false
	end

	local soulWarQuest = player:soulWarQuestKV()

	local playerId = player:getId()
	if MsgContains(message, "living") then
		npcHandler:sayLocalized("npc.flickering_soul.it_has_been_1", npc, player)
	elseif MsgContains(message, "mortal") then
		npcHandler:sayLocalized("npc.flickering_soul.i_had_many_2", npc, player)
	elseif MsgContains(message, "Goshnar") then
		npcHandler:say({
			"I was once known as the necromant king. ...",
			"For some it was meant as a curse, others used the name with reverence. To me it was just another stepping stone, in a life that burned with ambition.",
		}, npc, player, 4000)
	elseif MsgContains(message, "ambition") then
		npcHandler:say({
			"My ambitions were high and knew no limits. Mastery over life and death was but a milestone that I wanted to accomplish. In the end I aspired probably somewhat like godhood. ...",
			"Though in hindsight even that wouldn't have been enough. There was a hunger in me that nothing could put to rest.",
		}, npc, player, 4000)
	elseif MsgContains(message, "milestone") then
		npcHandler:sayLocalized("npc.flickering_soul.everything_in_my_3", npc, player)
	elseif MsgContains(message, "everything") then
		npcHandler:sayLocalized("npc.flickering_soul.necromancy_was_a_4", npc, player)
	elseif MsgContains(message, "accomplish") then
		npcHandler:say({
			"I was so convinced about my brilliance, my greatness, my destiny. And this hunger for more, it let me not have peace at any point in my life. I was always driven. There was no time to rest. ...",
			"And there was no looking back. I never cared to remember my humble beginnings, what I had sacrificed to get where I was. All that I had left behind and that I had lost forever. ...",
			"Now I see the bitter irony. I could bring back the dead, but I couldn't create second chances. I couldn't restore the truly important things that I had lost.",
		}, npc, player, 4000)
	elseif MsgContains(message, "dead") then
		npcHandler:sayLocalized("npc.flickering_soul.my_demise_did_5", npc, player)
	elseif MsgContains(message, "confident") then
		npcHandler:sayLocalized("npc.flickering_soul.my_soul_wandered_6", npc, player)
	elseif MsgContains(message, "peace") then
		npcHandler:say({
			"Zarganash was not a place without its dangers, but for a soul as powerful as mine, there was little threat at all. For the first time in my existence I had to stop running forward. I had to wait for things to fit into their places. ...",
			"And me, who had seen things that horrible, they would have obliterated a lesser man's mind, finally took the time to look back. And what I saw was frightening in its own right. ...",
			"A great tiredness overcame me. With the flames of my ambitions calming down for the first time since I could remember, all my aspirations and plans seemed to petty and futile. ...",
			"Everything I had worked for and my plans for the things to come seemed pointless, and the things I had lost and never allowed myself to experience weighed heavily on my soul.",
		}, npc, player, 4000)
	elseif MsgContains(message, "soul") then
		npcHandler:say({
			"I talked to other souls, lost in Zarganash, and most of them seemed like mirrors to myself. Their faults, their shortcomings, the things that were important to them and the things they had lost. ...",
			"It was all like miniature copies of my own grand plans and losses. It made me think. And the great tiredness weighed even more heavy on me. A weariness of the world, of the hunger that drove me.",
		}, npc, player, 4000)
	elseif MsgContains(message, "weariness") then
		npcHandler:say({
			"Then I met a wise soul. A teacher that did not lecture. I never was impressed by anything but my own accomplishments. But the inner balance and peace of this soul, it did impress me. A lot. ...",
			"I, who fancied myself to have been the epitome of knowledge, learned things that were entirely new to me. But this knowledge wasn't about power. It was about me.",
		}, npc, player, 4000)
	elseif MsgContains(message, "knowledge") then
		npcHandler:sayLocalized("npc.flickering_soul.i_recognized_the_7", npc, player)
	elseif MsgContains(message, "return") then
		npcHandler:say({
			"I decided to stay here, even pass on into the great beyond at some point. Yet I still feel the pull of my fetters. I can faintly hear those who think they are my followers, calling to me.",
			"And I feel others, many others who crave my powers and try to bring me back for their own gain.",
		}, npc, player, 4000)
	elseif MsgContains(message, "fetters") then
		npcHandler:say({
			"Over my time in Zarganash I split away the parts of me that my worldly fetters were bound to. Yet I had to recognize that they are still a part of me and I'm bound to them. ...",
			"The fetters and the efforts to call me back are empowering them. I feel them growing in strength and gaining awareness on their own. ...",
			"They are beginning to feed not only on the fetters and incarnations but also on me. As I grow weaker, they grow more powerful over time.",
		}, npc, player, 4000)
	elseif MsgContains(message, "powerful") then
		npcHandler:sayLocalized("npc.flickering_soul.the_only_way_8", npc, player)
	elseif MsgContains(message, "task") then
		local soulWarQuest = player:soulWarQuestKV()
		-- Checks if the boss has already been defeated
		if soulWarQuest:get("goshnar's-megalomania-killed") then
			npcHandler:say({
				"You did it! For the first time I can feel free from the pull of my past. Now I'm free at last. ...",
				"I might stay a while and teach other souls about the inner peace, but will eventually pass on. Thank you so much, my hero. My eternal gratitude and blessings will be with you!",
			}, npc, player, 2000)
			npcHandler:setTopic(playerId, 2)
			player:addOutfit("Revenant")
		else
			npcHandler:sayLocalized("npc.flickering_soul.im_aware_i_9", npc, player)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		npcHandler:sayLocalized("npc.flickering_soul.thank_you_for_10", npc, player)
		soulWarQuest:set("teleport-access", true)
	elseif MsgContains(message, "burden") then
		npcHandler:say({
			"You will have to reach each of the negative parts of my personality that I split away. They are hidden deep in the depths of Zarganash and will have corrupted and twisted their surroundings into dangerous nightmares. ...",
			"Even worse, you'll likely encounter minions of those who want to claim my soul as their prize for their own depraved reasons. You will have to destroy my shards to set me free.",
		}, npc, player, 5000)
	elseif MsgContains(message, "shards") then
		npcHandler:sayLocalized("npc.flickering_soul.you_havent_killed_11", npc, player)
	elseif MsgContains(message, "hate") then
		npcHandler:say({
			"I hated the world for its flaws and the reluctance of people to comply with my will. I was convinced I was destined for greatness and to change everything. Ordinary beings were far beneath me and my consideration. ...",
			"All this opposition, all the wars were a nuisance on my way to greatness. I would have sacrificed the whole world to reach my goals.",
		}, npc, player, 4000)
	elseif MsgContains(message, "fermuba") then
		npcHandler:sayLocalized("npc.flickering_soul.my_daughter_was_12", npc, player)
	elseif MsgContains(message, "ferumbras") then
		npcHandler:say({
			"Even in the lands of the dead, this one caused a stir. The dead were whispering his name. It made me feel jealous and angry at first, but at some point, after much self-reflection, I could recognize my own faults in the stories about him.",
			"It was almost like looking into a mirror for the first time. However, he lived way later than me, and I never met his soul here, so I can't tell more about him.",
		}, npc, player, 4000)
	elseif MsgContains(message, "grandson") then
		npcHandler:sayLocalized("npc.flickering_soul.im_not_aware_13", npc, player)
	elseif MsgContains(message, "pale worm") then
		npcHandler:sayLocalized("npc.flickering_soul.his_avatar_might_14", npc, player)
	elseif MsgContains(message, "necromant king") then
		npcHandler:say({
			"They called me the necromant king, in an act of reverence, but to me it was always more of a slander. To limit my greatness to this insignificant aspect was an insult to my ego. But I let it slip for the greater good. ...",
			"I felt it was beneath me to correct them and I went along.",
		}, npc, player, 4000)
	elseif MsgContains(message, "minions") or MsgContains(message, "followers") then
		npcHandler:sayLocalized("npc.flickering_soul.i_despised_my_15", npc, player)
	elseif MsgContains(message, "shards") then
		local bossesYetToDefeat = {}
		for bossName, _ in pairs(SoulWarQuest.miniBosses) do
			if not soulWarQuest:get(bossName) then
				table.insert(bossesYetToDefeat, bossName)
			end
		end

		local message
		if #bossesYetToDefeat > 0 then
			message = "You haven't killed " .. table.concat(bossesYetToDefeat, ", ") .. " yet."
		else
			message = "You have defeated all the Goshnar's Bosses. Your soul shines brighter with each victory."
		end
		npcHandler:say(message, npc, player)
	elseif MsgContains(message, "taints") or MsgContains(message, "penalties") then
		if player:getTaintLevel() ~= nil then
			player:resetTaints(true)
			npcHandler:sayLocalized("npc.flickering_soul.i_have_cleansed_16", npc, player)
			return
		end

		npcHandler:sayLocalized("npc.flickering_soul.you_are_not_17", npc, player)
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, playerSayCallback)

npcHandler:setMessage(MESSAGE_GREET, "Be greeted, living soul!")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
