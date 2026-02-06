local LEVEL_LOWER = 1
local LEVEL_SAME = 2
local LEVEL_HIGHER = 3

local DISTANCE_BESIDE = 1
local DISTANCE_CLOSE = 2
local DISTANCE_FAR = 3
local DISTANCE_VERYFAR = 4

local directions = {
	[DIRECTION_NORTH] = "scripts.find_person.dir_north",
	[DIRECTION_SOUTH] = "scripts.find_person.dir_south",
	[DIRECTION_EAST] = "scripts.find_person.dir_east",
	[DIRECTION_WEST] = "scripts.find_person.dir_west",
	[DIRECTION_NORTHEAST] = "scripts.find_person.dir_northeast",
	[DIRECTION_NORTHWEST] = "scripts.find_person.dir_northwest",
	[DIRECTION_SOUTHEAST] = "scripts.find_person.dir_southeast",
	[DIRECTION_SOUTHWEST] = "scripts.find_person.dir_southwest",
}

local messages = {
	[DISTANCE_BESIDE] = {
		[LEVEL_LOWER] = "scripts.find_person.beside_lower",
		[LEVEL_SAME] = "scripts.find_person.beside_same",
		[LEVEL_HIGHER] = "scripts.find_person.beside_higher",
	},
	[DISTANCE_CLOSE] = {
		[LEVEL_LOWER] = "scripts.find_person.close_lower",
		[LEVEL_SAME] = "scripts.find_person.close_same",
		[LEVEL_HIGHER] = "scripts.find_person.close_higher",
	},
	[DISTANCE_FAR] = "scripts.find_person.far",
	[DISTANCE_VERYFAR] = "scripts.find_person.veryfar",
}

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local target = Player(variant:getString())
	if not target or target:getGroup():getAccess() and not creature:getGroup():getAccess() then
		creature:sendCancelMessage(RETURNVALUE_PLAYERWITHTHISNAMEISNOTONLINE)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local targetPosition = target:getPosition()
	local creaturePosition = creature:getPosition()
	local positionDifference = {
		x = creaturePosition.x - targetPosition.x,
		y = creaturePosition.y - targetPosition.y,
		z = creaturePosition.z - targetPosition.z,
	}

	local maxPositionDifference, direction = math.max(math.abs(positionDifference.x), math.abs(positionDifference.y))
	if maxPositionDifference >= 5 then
		local positionTangent = positionDifference.x ~= 0 and positionDifference.y / positionDifference.x or 10
		if math.abs(positionTangent) < 0.4142 then
			direction = positionDifference.x > 0 and DIRECTION_WEST or DIRECTION_EAST
		elseif math.abs(positionTangent) < 2.4142 then
			direction = positionTangent > 0 and (positionDifference.y > 0 and DIRECTION_NORTHWEST or DIRECTION_SOUTHEAST) or positionDifference.x > 0 and DIRECTION_SOUTHWEST or DIRECTION_NORTHEAST
		else
			direction = positionDifference.y > 0 and DIRECTION_NORTH or DIRECTION_SOUTH
		end
	end

	local level = positionDifference.z > 0 and LEVEL_HIGHER or positionDifference.z < 0 and LEVEL_LOWER or LEVEL_SAME
	local distance = maxPositionDifference < 5 and DISTANCE_BESIDE or maxPositionDifference < 101 and DISTANCE_CLOSE or maxPositionDifference < 275 and DISTANCE_FAR or DISTANCE_VERYFAR
	local messageKey = messages[distance][level] or messages[distance]
	local player = creature:getPlayer()
	local msgText = Translator.getTranslation(player, messageKey)
	if distance ~= DISTANCE_BESIDE then
		local dirText = Translator.getTranslation(player, directions[direction])
		msgText = msgText .. " " .. dirText
	end

	creature:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.find_person.result", {
		target:getName(),
		msgText,
	})
	creaturePosition:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

spell:name("Find Person")
spell:words("exiva")
spell:group("support")
spell:vocation("druid;true", "elder druid;true", "knight;true", "elite knight;true", "paladin;true", "royal paladin;true", "sorcerer;true", "master sorcerer;true")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_FIND_PERSON)
spell:id(20)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(8)
spell:mana(20)
spell:hasParams(true)
spell:hasPlayerNameParam(true)
spell:isAggressive(false)
spell:needLearn(false)
spell:register()
