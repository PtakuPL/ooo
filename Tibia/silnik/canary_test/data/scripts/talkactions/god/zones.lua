local zones = TalkAction("/zones")

function zones.onSay(player, words, param)
	local params = string.split(param, ",")
	local cmd = params[1]
	if not cmd then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.zones.msg_1")
		return true
	end

	if cmd == "list" then
		local list = {}
		local filter = params[2] and params[2]:trim()
		for _, zone in ipairs(Zone.getAll()) do
			if filter then
				if not zone:getName():lower():find(filter:lower()) then
					goto continue
				end
			end
			table.insert(list, zone:getName())
			::continue::
		end
		player:sendLocalizedTextMessage(MESSAGE_HEALED, "god.zones.list", {table.concat(list, "\n ")})
		return true
	end

	local function zoneFromParam()
		local zoneName = params[2]:trim()
		if not zoneName then
			player:sendLocalizedMessage(MESSAGE_HEALED, "scripts.zones.msg_2")
			return true
		end
		local zone = Zone.getByName(zoneName)
		if not zone then
			player:sendLocalizedMessage(MESSAGE_HEALED, "scripts.zones.msg_3")
			return true
		end
		return zone
	end

	local commands = {
		["goto"] = function(zone)
			local pos = zone:randomPosition()
			if not pos then
				player:sendLocalizedMessage(MESSAGE_HEALED, "scripts.zones.msg_4")
				return true
			end
			player:teleportTo(pos)
			player:sendLocalizedMessage(MESSAGE_HEALED, "scripts.zones.msg_5" .. zone:getName() .. ".")
		end,
		removeMonsters = function(zone)
			zone:removeMonsters()
			player:sendLocalizedMessage(MESSAGE_HEALED, "scripts.zones.msg_6" .. zone:getName() .. ".")
		end,
		countMonsters = function(zone)
			local monsters = zone:getMonsters()
			player:sendLocalizedTextMessage(MESSAGE_HEALED, "god.zones.count_monsters", {zone:getName(), tostring(#monsters)})
		end,
		removeNpcs = function(zone)
			zone:removeNpcs()
			player:sendLocalizedMessage(MESSAGE_HEALED, "scripts.zones.msg_7" .. zone:getName() .. ".")
		end,
		countNpcs = function(zone)
			local npcs = zone:getNpcs()
			player:sendLocalizedTextMessage(MESSAGE_HEALED, "god.zones.count_npcs", {zone:getName(), tostring(#npcs)})
		end,
		kickPlayers = function(zone)
			zone:removePlayers()
			player:sendLocalizedMessage(MESSAGE_HEALED, "scripts.zones.msg_8" .. zone:getName() .. ".")
		end,
		listPlayers = function(zone)
			local players = zone:getPlayers()
			local list = {}
			for _, player in ipairs(players) do
				table.insert(list, player:getName())
			end
			player:sendLocalizedTextMessage(MESSAGE_HEALED, "god.zones.list_players", {zone:getName(), table.concat(list, ", ")})
		end,
		countPlayers = function(zone)
			local players = zone:getPlayers()
			player:sendLocalizedTextMessage(MESSAGE_HEALED, "god.zones.count_players", {zone:getName(), tostring(#players)})
		end,
		size = function(zone)
			local positions = zone:getPositions()
			player:sendLocalizedTextMessage(MESSAGE_HEALED, "god.zones.zone_size", {zone:getName(), tostring(#positions)})
		end,
	}

	local command = commands[cmd]
	if not command then
		player:sendLocalizedMessage(MESSAGE_HEALED, "scripts.zones.msg_9")
		return true
	end
	local zone = zoneFromParam()
	if not zone then
		return true
	end
	return command(zone)
end

zones:separator(" ")
zones:groupType("god")
zones:register()
