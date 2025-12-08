local dawnportAdvance = CreatureEvent("DawnportAdvance")
local dawnportEvents = {}

-- Teleport to the dawnport temple after reaching level 20 (the player has five minutes before being teleported)
local function teleportToDawnportTemple(uid)
	local player = Player(uid)
	table.remove(dawnportEvents, uid)
	-- If not have the Oressa storage, teleport player to the temple
	if player and player:getStorageValue(Storage.Dawnport.DoorVocation) == -1 then
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end
end

function dawnportAdvance.onAdvance(player, skill, oldLevel, newLevel)
	local town = player:getTown()
	-- Check that resides on dawnport
	if town and town:getId() == TOWNS_LIST.DAWNPORT then
		if skill == SKILL_LEVEL then
			-- Notify min level to leave dawnport
			if newLevel == 8 then
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "player.dawnport.level8")
				-- Notify max level to stay in dawnport
			elseif newLevel >= 20 then
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "player.dawnport.level20")
				if not dawnportEvents[player:getId()] then
					-- Adds the event that teleports the player to the temple in five minutes after reaching level 20
					dawnportEvents[player:getId()] = addEvent(teleportToDawnportTemple, 5 * 60 * 1000, player:getId())
				end
			end
			-- Notify reached a skill limit
		elseif skill ~= SKILL_LEVEL and isSkillGrowthLimited(player, skill) then
			if skill == SKILL_MAGLEVEL then
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "player.dawnport.magic_limit")
			else
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "player.dawnport.skill_limit")
			end
		end
	end
	return true
end

dawnportAdvance:register()
