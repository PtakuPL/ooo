-- Arena PvP - Mode: 3v3 Team
-- Two teams of three players

ArenaModes = ArenaModes or {}

ArenaModes.Team3v3 = {
	mode = Arena.MODE_3V3,
	name = "3v3 Team",
	playersRequired = 6,
	teams = 2,
	playersPerTeam = 3,
	duration = 10 * 60,  -- 10 minutes
	respawn = false,

	spawnOffsets = {
		[1] = {
			{ x = -6, y = -2 },
			{ x = -6, y = 0 },
			{ x = -6, y = 2 },
		},
		[2] = {
			{ x = 6, y = -2 },
			{ x = 6, y = 0 },
			{ x = 6, y = 2 },
		},
	},

	--- Check win condition: all members of one team eliminated
	---@param matchData table
	---@return number? winnerTeam
	checkWin = function(matchData)
		local teamAlive = { [1] = 0, [2] = 0 }
		for _, pData in ipairs(matchData.players) do
			if pData.deaths == 0 then
				teamAlive[pData.team] = (teamAlive[pData.team] or 0) + 1
			end
		end

		if teamAlive[1] == 0 then return 2 end
		if teamAlive[2] == 0 then return 1 end
		return nil
	end,
}
