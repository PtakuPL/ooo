local specialItemRanges = {
	{ rangeStart = ITEM_HEALTH_CASK_START, rangeEnd = ITEM_HEALTH_CASK_END },
	{ rangeStart = ITEM_MANA_CASK_START, rangeEnd = ITEM_MANA_CASK_END },
	{ rangeStart = ITEM_SPIRIT_CASK_START, rangeEnd = ITEM_SPIRIT_CASK_END },
	{ rangeStart = ITEM_KEG_START, rangeEnd = ITEM_KEG_END },
}

local function isSpecialItem(itemId)
	for _, range in ipairs(specialItemRanges) do
		if itemId >= range.rangeStart and itemId <= range.rangeEnd then
			return true
		end
	end
	return false
end

local function getPositionDescription(position, player)
	if position.x == 65535 then
		return Translator.getTranslation(player, "scripts.on_look.position_inventory")
	else
		return string.format(Translator.getTranslation(player, "scripts.on_look.position_coords"), position.x, position.y, position.z)
	end
end

local function handleItemDescription(inspectedThing, lookDistance, player)
	local descriptionText = inspectedThing:getDescription(lookDistance, player)

	if not player:getGroup():getAccess() then
		if inspectedThing:getId() == ITEM_MAGICWALL or inspectedThing:getId() == ITEM_MAGICWALL_SAFE then
			return Translator.getTranslation(player, "scripts.on_look.magic_wall")
		elseif inspectedThing:getId() == ITEM_WILDGROWTH or inspectedThing:getId() == ITEM_WILDGROWTH_SAFE then
			return Translator.getTranslation(player, "scripts.on_look.rush_wood")
		end
	end
	if isSpecialItem(inspectedThing.itemid) then
		local itemCharges = inspectedThing:getCharges()
		if itemCharges > 0 then
			return string.format(Translator.getTranslation(player, "scripts.on_look.see_refillings"), descriptionText, itemCharges)
		end
	else
		return string.format(Translator.getTranslation(player, "scripts.on_look.see_prefix"), descriptionText)
	end

	return descriptionText
end

local function handleCreatureDescription(inspectedThing, lookDistance, player)
	local descriptionText = inspectedThing:getDescription(lookDistance)

	if inspectedThing:isMonster() then
		local monsterMaster = inspectedThing:getMaster()
		if monsterMaster and table.contains({ "sorcerer familiar", "knight familiar", "druid familiar", "paladin familiar" }, inspectedThing:getName():lower()) then
			local summonTimeRemaining = monsterMaster:kv():get("familiar-summon-time") or 0
			descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.familiar_master"), descriptionText, monsterMaster:getName(), Game.getTimeInWords(summonTimeRemaining - os.time()))
		end
	end

	return string.format(Translator.getTranslation(player, "scripts.on_look.see_prefix"), descriptionText)
end

local function appendAdminDetails(descriptionText, inspectedThing, inspectedPosition, player)
	if inspectedThing:isItem() then
		descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.admin_client_id"), descriptionText, inspectedThing:getId())

		local itemActionId = inspectedThing:getActionId()
		if itemActionId ~= 0 then
			descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.admin_action_id"), descriptionText, itemActionId)
		end

		local itemUniqueId = inspectedThing:getUniqueId()
		if itemUniqueId > 0 and itemUniqueId < 65536 then
			descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.admin_unique_id"), descriptionText, itemUniqueId)
		end

		local doorIdAttribute = inspectedThing:getAttribute(ITEM_ATTRIBUTE_DOORID)
		if doorIdAttribute and doorIdAttribute > 0 then
			descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.admin_door_id"), descriptionText, doorIdAttribute)
		end

		local itemType = inspectedThing:getType()
		local transformOnEquipId = itemType:getTransformEquipId()
		local transformOnDeEquipId = itemType:getTransformDeEquipId()

		if transformOnEquipId ~= 0 then
			descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.admin_transform_equip"), descriptionText, transformOnEquipId)
		elseif transformOnDeEquipId ~= 0 then
			descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.admin_transform_deequip"), descriptionText, transformOnDeEquipId)
		end

		local itemDecayId = itemType:getDecayId()
		if itemDecayId ~= -1 then
			descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.admin_decay"), descriptionText, itemDecayId)
		end
	elseif inspectedThing:isCreature() then
		local healthDescription, creatureId = Translator.getTranslation(player, "scripts.on_look.admin_player_health")
		if inspectedThing:isPlayer() and inspectedThing:getMaxMana() > 0 then
			creatureId = string.format(Translator.getTranslation(player, "scripts.on_look.admin_player_id"), inspectedThing:getGuid())
			healthDescription = string.format(Translator.getTranslation(player, "scripts.on_look.admin_player_health_mana"), healthDescription, inspectedThing:getMana(), inspectedThing:getMaxMana())
		elseif inspectedThing:isMonster() then
			creatureId = string.format(Translator.getTranslation(player, "scripts.on_look.admin_monster_id"), inspectedThing:getId())
		elseif inspectedThing:isNpc() then
			creatureId = string.format(Translator.getTranslation(player, "scripts.on_look.admin_npc_id"), inspectedThing:getId())
		end

		descriptionText = string.format(healthDescription, descriptionText, creatureId, inspectedThing:getHealth(), inspectedThing:getMaxHealth())
	end

	descriptionText = string.format("%s\n%s", descriptionText, getPositionDescription(inspectedPosition, player))

	if inspectedThing:isCreature() then
		local creatureBaseSpeed = inspectedThing:getBaseSpeed()
		local creatureCurrentSpeed = inspectedThing:getSpeed()
		descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.admin_speed"), descriptionText, creatureBaseSpeed, creatureCurrentSpeed)

		if inspectedThing:isPlayer() then
			descriptionText = string.format(Translator.getTranslation(player, "scripts.on_look.admin_ip"), descriptionText, Game.convertIpToString(inspectedThing:getIp()))
		end
	end

	return descriptionText
end

local callback = EventCallback("PlayerOnLookBaseEvent")

function callback.playerOnLook(player, inspectedThing, inspectedPosition, lookDistance)
	local descriptionText

	if inspectedThing:isItem() then
		descriptionText = handleItemDescription(inspectedThing, lookDistance, player)
	elseif inspectedThing:isCreature() then
		descriptionText = handleCreatureDescription(inspectedThing, lookDistance, player)
	end

	if player:getGroup():getAccess() then
		descriptionText = appendAdminDetails(descriptionText, inspectedThing, inspectedPosition, player)
	end

	player:sendTextMessage(MESSAGE_LOOK, descriptionText)
end

callback:register()
