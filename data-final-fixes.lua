require "config"
require "constants"

local recipes = {}

local function createSteamRecipe(recipe)
	local copy = nil
	if recipe.category == "smelting" or recipe.category == "chemical-furnace" or recipe.category == "mixing-furnace" then
		copy = table.deepcopy(recipe)
		copy.name = copy.name .. "-steam"
		copy.category = "steam-" .. copy.category
		copy.enabled = true
		if copy.ingredients then
			table.insert(copy.ingredients, {type="fluid", name="steam", amount=5})
		end
		if copy.normal and copy.normal.ingredients then
			table.insert(copy.normal.ingredients, {type="fluid", name="steam", amount=5})
		end
		if copy.expensive and copy.expensive.ingredients then
			table.insert(copy.expensive.ingredients, {type="fluid", name="steam", amount=10})
		end
		copy.allow_decomposition = false
		log("Created a steam version of smelting recipe '" .. recipe.name .. "'")
	end
	return copy
end

if Config.enableSteamFurnace then
	for name,recipe in pairs(data.raw.recipe) do
		local copy = createSteamRecipe(recipe)
		if copy then
			table.insert(recipes, copy)
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
						if not recipe then log("Tech set to unlock recipe '" .. effect.recipe .. "', which does not exist?!") end
						if recipe then
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
			if recipe.results then
				for _,result in pairs(recipe.results) do
					amt = amt+result.amount
					result.amount = result.amount/refineryItemConsumption
				end
			else
				amt = amt+recipe.result.amount
			end
			amt = 5*math.floor((amt/4)/5+0.5)
			
			local added = false
			for _,ingredient in pairs(recipe.ingredients) do
				if ingredient.name == "water" then
					--ingredient.amount = ingredient.amount+amt
					--added = true
				elseif ingredient.type == "fluid" then
					ingredient.amount = ingredient.amount/refineryItemConsumption
				end
			end
			if not added then
				table.insert(recipe.ingredients, 1, {type="fluid", name="water", amount=amt*refineryWasteProductionRatio/refineryItemConsumption})
			end

			if data.raw.item["carbon"] then
				table.insert(recipe.ingredients, {"carbon", 1})
			else
				--table.insert(recipe.ingredients, {"coal", 2})
			end

			if data.raw.item["calcium-chloride"] then
				table.insert(recipe.ingredients, {"calcium-chloride", 1})
			end

			if data.raw.item["sodium-hydroxide"] then
				table.insert(recipe.ingredients, {"sodium-hydroxide", 2})
			end
			
			if data.raw.item["air-filter-case"] then
				table.insert(recipe.ingredients, {"air-filter", 1})
			end
			
			table.insert(recipe.results, {type="fluid", name="waste", amount=amt*refineryWasteProductionRatio/refineryItemConsumption})
						
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
						if not recipe then log("Tech set to unlock recipe '" .. effect.recipe .. "', which does not exist?!") end
						if recipe then
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

if data.raw.technology["concrete-2"] then
	table.insert(data.raw.technology["advanced-pollution-capture-2"].prerequisites, "concrete-2")
end

if data.raw.item["tin-plate"] then
	table.insert(data.raw.recipe["air-filter-machine-2"].ingredients, {type="item", name="tin-plate", amount=8})
end

if data.raw.item["invar-alloy"] then
	table.insert(data.raw.recipe["air-filter-machine-3"].ingredients, {type="item", name="invar-alloy", amount=8})
	table.insert(data.raw.technology["advanced-pollution-capture"].prerequisites, "invar-processing")
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