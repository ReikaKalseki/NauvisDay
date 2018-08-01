require "config"
require "constants"

local recipes = {}

if Config.enableSteamFurnace then
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
			copy.allow_decomposition = false
		end
	end

	for _,recipe in pairs(recipes) do
		data:extend({recipe})
	end

	for _,tech in pairs(data.raw.technology) do
		if tech.effects then
			for _,ir in pairs(recipes) do
				for _,effect in pairs(tech.effects) do
					if effect.type == "unlock-recipe" then
						local recipe = data.raw.recipe[effect.recipe]
						if not recipe then error("Tech set to unlock recipe '" .. effect.recipe .. "', which does not exist?!") end
						if ir.name == recipe.name .. "-steam" then
							table.insert(tech.effects, {type="unlock-recipe", recipe=ir.name})
							ir.enabled = "false"
							log("Adding " .. ir.name .. " to unlock list for " .. tech.name)
							break
						end
					end
				end
			end
		end
	end
end

recipes = {}

if Config.enableRefinery then
	for name,recipe in pairs(data.raw.recipe) do --do later to handle the water->steam conversion some mods do
		if recipe.category == "oil-processing" then
			recipe = table.deepcopy(recipe)
			recipe.category = "clean-oil-processing"
			recipe.name = "clean-" .. name
			recipe.localised_name = {"clean-refining.name", {"recipe-name." .. name}}
			local amt = 0
			for _,result in pairs(recipe.results) do
				amt = amt+result.amount
			end
			amt = 5*math.floor((amt/4)/5+0.5)
			
			local added = false
			for _,ingredient in pairs(recipe.ingredients) do
				if ingredient.name == "water" then
					--ingredient.amount = ingredient.amount+amt
					--added = true
				end
			end
			if not added then
				table.insert(recipe.ingredients, 1, {type="fluid", name="water", amount=amt})
			end

			if data.raw.item["carbon"] then
				table.insert(recipe.ingredients, {"carbon", 2})
			else
				--table.insert(recipe.ingredients, {"coal", 2})
			end

			if data.raw.item["calcium-chloride"] then
				table.insert(recipe.ingredients, {"calcium-chloride", 2})
			end

			if data.raw.item["sodium-hydroxide"] then
				table.insert(recipe.ingredients, {"sodium-hydroxide", 2})
			end
			
			if data.raw.item["air-filter-case"] then
				table.insert(recipe.ingredients, {"air-filter", 1})
			end
			
			table.insert(recipe.results, {type="fluid", name="waste", amount=amt})
						
			if data.raw.item["air-filter-case"] then
				table.insert(recipe.results, {"air-filter-case", 1})
			end
			
			log("Added a clean version of " .. name)
			data:extend({recipe})
			
			table.insert(recipes, recipe)
			
		end
	end

	for _,tech in pairs(data.raw.technology) do
		if tech.effects then
			for _,ir in pairs(recipes) do
				for _,effect in pairs(tech.effects) do
					if effect.type == "unlock-recipe" then
						local recipe = data.raw.recipe[effect.recipe]
						if not recipe then error("Tech set to unlock recipe '" .. effect.recipe .. "', which does not exist?!") end
						if ir.name == "clean-" .. recipe.name then
							table.insert(tech.effects, {type="unlock-recipe", recipe=ir.name})
							ir.enabled = "false"
							log("Adding " .. ir.name .. " to unlock list for " .. tech.name)
							break
						end
					end
				end
			end
		end
	end
end

if data.raw.technology["bob-greenhouse"] then
	data.raw.recipe.greenhouse.enabled = "false"
	table.insert(data.raw.technology["bob-greenhouse"].effects, {type = "unlock-recipe", recipe = "greenhouse"})
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