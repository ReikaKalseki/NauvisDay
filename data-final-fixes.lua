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
data.raw.item["rubber-floor"].stack_size = data.raw.item.concrete.stack_size

if data.raw.item.rubber then
	data.raw.recipe["rubber-floor"].ingredients = {{type="item", name="rubber", amount=20}}
else
	data.raw.item["rubber-floor"].localised_name = {"item-name.iron-floor"}
	data.raw.tile["rubber-floor"].localised_name = {"tile-name.iron-floor"}
end

--[[
local rubbers = {}
for name,tile in pairs(data.raw.tile) do
	local rubber = table.deepcopy(data.raw.tile["rubber-floor"])
	rubber.ageing = tile.ageing
	rubber.name = name .. "-" .. rubber.name
	rubber.localised_name = "tile-name.rubber-floor"
end

for _,tile in pairs(rubbers) do
	data:extend({
		tile
	})
end
--]]