-- Arena PvP - Mode: Free For All (FFA)
-- Every player fights for themselves. Most kills wins.

ArenaModes = ArenaModes or {}

ArenaModes.FFA = {
	mode = Arena.MODE_FFA,
	name = "Free For All",
	playersRequired = 4,  -- minimum
	maxPlayers = 8,
	teams = 0,  -- no teams, every player is solo
	duration = 5 * 60,  -- 5 minutes
	respawn = true,  -- players respawn after death
	respawnDelay = 5, -- seconds

	--- Check win condition: time-based, most kills wins
	--- (Or last man standing if no respawn)
	---@param matchData table
	---@return number? winnerTeam (player's solo "team" index)
	checkWin = function(matchData)
		-- FFA is time-based; winner determined at match end
		-- C++ handles the timer; Lua only checks on timeout
		return nil
	end,

	--- Determine winner at end of match (time expired)
	---@param matchData table
	---@return number winnerTeam, string reason
	determineWinner = function(matchData)
		local bestPlayer = nil
		local bestKills = -1
		local bestDeaths = 999

		for _, pData in ipairs(matchData.players) do
			if pData.kills > bestKills or
				(pData.kills == bestKills and pData.deaths < bestDeaths) then
				bestKills = pData.kills
				bestDeaths = pData.deaths
				bestPlayer = pData
			end
		end

		if bestPlayer then
			return bestPlayer.team, "Most kills: " .. bestKills
		end
		return 0, "Draw"
	end,
}
