-- Arena PvP - Mode: Tournament
-- Bracket-style elimination. Special event mode.
-- Managed as a series of 1v1 or 2v2 matches.

ArenaModes = ArenaModes or {}

ArenaModes.Tournament = {
	mode = Arena.MODE_TOURNAMENT,
	name = "Tournament",
	playersRequired = 8,  -- minimum bracket size
	maxPlayers = 32,
	teams = 2,  -- per individual match
	duration = 10 * 60,  -- per match
	respawn = false,

	-- Tournament is managed as a special event
	-- Each round pairs winners against each other
	-- This is a placeholder for the tournament bracket logic

	--- Check win condition (same as 1v1 per round)
	---@param matchData table
	---@return number? winnerTeam
	checkWin = function(matchData)
		for _, pData in ipairs(matchData.players) do
			if pData.deaths > 0 then
				return (pData.team == 1) and 2 or 1
			end
		end
		return nil
	end,
}
