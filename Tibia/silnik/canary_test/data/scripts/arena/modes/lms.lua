-- Arena PvP - Mode: Last Man Standing (LMS)
-- No respawns. Last player alive wins.

ArenaModes = ArenaModes or {}

ArenaModes.LMS = {
	mode = Arena.MODE_LMS,
	name = "Last Man Standing",
	playersRequired = 4,  -- minimum
	maxPlayers = 16,
	teams = 0,  -- solo
	duration = 15 * 60,  -- 15 minutes
	respawn = false,

	--- Check win condition: only one player left alive
	---@param matchData table
	---@return number? winnerTeam
	checkWin = function(matchData)
		local aliveCount = 0
		local lastAlive = nil

		for _, pData in ipairs(matchData.players) do
			if pData.deaths == 0 then
				aliveCount = aliveCount + 1
				lastAlive = pData
			end
		end

		-- Only one player remaining = winner
		if aliveCount == 1 and lastAlive then
			return lastAlive.team
		end

		-- No one alive = draw
		if aliveCount == 0 then
			return 0
		end

		return nil  -- match continues
	end,
}
