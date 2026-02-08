local recipeKeys = {
	"scripts.hot_cuisine.recipe_11",
	"scripts.hot_cuisine.recipe_12",
	"scripts.hot_cuisine.recipe_13",
	"scripts.hot_cuisine.recipe_14",
}

local hotCuisineCook2 = Action()
function hotCuisineCook2.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local text = {}
	for i = 1, #recipeKeys do
		text[#text + 1] = Translator.getTranslation(player, recipeKeys[i])
	end
	player:showTextDialog(item.itemid, table.concat(text))
	return true
end

hotCuisineCook2:id(11541)
hotCuisineCook2:register()
