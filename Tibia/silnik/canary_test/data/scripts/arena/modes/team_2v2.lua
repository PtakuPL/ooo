-- Arena PvP - Mode: 2v2 Team
-- Two teams of two players

ArenaModes = ArenaModes or {}

ArenaModes.Team2v2 = {
	mode = Arena.MODE_2V2,
	name = "2v2 Team",
	playersRequired = 4,
	teams = 2,
	playersPerTeam = 2,
	duration = 7 * 60,  -- 7 minutes
	respawn = false,

	spawnOffsets = {
		[1] = {
			{ x = -5, y = -1 },
			{ x = -5, y = 1 },
		},
		[2] = {
			{ x = 5, y = -1 },
			{ x = 5, y = 1 },
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
