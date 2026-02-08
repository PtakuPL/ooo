local OPCODE_LANGUAGE = 1

local extendedOpcode = CreatureEvent("ExtendedOpcode")

local function sanitizeLocale(locale)
	if type(locale) ~= "string" then
		return nil
	end

	locale = locale:lower():gsub("[^%w_-]", "")
	if locale == "" then
		return nil
	end

	if #locale > 5 then
		locale = locale:sub(1, 5)
	end

	return locale
end

function extendedOpcode.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= OPCODE_LANGUAGE then
		return true
	end

	local locale = sanitizeLocale(buffer)
	if not locale then
		return true
	end

	player:setLocale(locale)
	return true
end

extendedOpcode:register()
