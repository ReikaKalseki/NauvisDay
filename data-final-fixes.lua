local recipes = {}

for name,recipe in pairs(data.raw.recipe) do
	if recipe.category == "smelting" then
		local copy = table.deepcopy(recipe)
		copy.name = copy.name .. "-steam"
		copy.category = "steam-smelting"
		if copy.ingredients then
			table.insert(copy.ingredients, {type="fluid", name="steam", amount=5})
		end
		if copy.normal and copy.normal.ingredients then
			table.insert(copy.normal.ingredients, {type="fluid", name="steam", amount=5})
		end
		if copy.expensive and copy.expensive.ingredients then
			table.insert(copy.expensive.ingredients, {type="fluid", name="steam", amount=10})
		end
		table.insert(recipes, copy)
	end
end

for _,recipe in pairs(recipes) do
	data:extend({recipe})
end

data.raw.item.asphalt.stack_size = data.raw.item.concrete.stack_size