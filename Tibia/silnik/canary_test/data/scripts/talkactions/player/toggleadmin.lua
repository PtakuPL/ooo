-- !toggleadmin — przełącza między trybem Admin (GOD) a trybem Gracza (NORMAL)
-- Dostępne tylko dla kont z account_type = ACCOUNT_TYPE_GOD (5)
-- Storage 999999: 0 = tryb admin, 1 = tryb gracza

local STORAGE_ADMIN_TOGGLE = 999999

local toggleAdmin = TalkAction("!toggleadmin")

function toggleAdmin.onSay(player, words, param)
	if player:getAccountType() ~= ACCOUNT_TYPE_GOD then
		player:sendTextMessage(MESSAGE_FAILURE, "[ToggleAdmin] Tylko konta GOD moga uzywac tej komendy.")
		return true
	end

	local isPlayerMode = player:getStorageValue(STORAGE_ADMIN_TOGGLE) == 1

	if isPlayerMode then
		-- przełącz na tryb Admin
		if player:setGroup(Group(GROUP_TYPE_GOD)) then
			player:setStorageValue(STORAGE_ADMIN_TOGGLE, 0)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[ToggleAdmin] Tryb ADMIN wlaczony. Masz dostep do komend GM.")
		else
			player:sendTextMessage(MESSAGE_FAILURE, "[ToggleAdmin] Blad - nie mozna przelaczac grupy.")
		end
	else
		-- przełącz na tryb Gracza
		if player:setGroup(Group(GROUP_TYPE_NORMAL)) then
			player:setStorageValue(STORAGE_ADMIN_TOGGLE, 1)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[ToggleAdmin] Tryb GRACZ wlaczony. Komendy GM wylaczone.")
		else
			player:sendTextMessage(MESSAGE_FAILURE, "[ToggleAdmin] Blad - nie mozna przelaczac grupy.")
		end
	end

	return true
end

toggleAdmin:separator(" ")
toggleAdmin:groupType("normal")
toggleAdmin:register()
