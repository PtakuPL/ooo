local recipeKeys = {
	"scripts.hot_cuisine.recipe_1",
	"scripts.hot_cuisine.recipe_2",
	"scripts.hot_cuisine.recipe_3",
	"scripts.hot_cuisine.recipe_4",
	"scripts.hot_cuisine.recipe_5",
	"scripts.hot_cuisine.recipe_6",
	"scripts.hot_cuisine.recipe_7",
	"scripts.hot_cuisine.recipe_8",
	"scripts.hot_cuisine.recipe_9",
	"scripts.hot_cuisine.recipe_10",
}

local hotCuisineCook1 = Action()
function hotCuisineCook1.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local text = {}
	for i = 1, #recipeKeys do
		text[#text + 1] = Translator.getTranslation(player, recipeKeys[i])
	end
	player:showTextDialog(item.itemid, table.concat(text))
	return true
end

hotCuisineCook1:id(9093)
hotCuisineCook1:register()
