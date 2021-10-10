require "config"
require "constants"

local recipes = {}

local function modifyIngredients(recipe, wateramt, expensive)
	if recipe == nil or recipe.ingredients == nil then return end		
	if recipe.energy_required then
		recipe.energy_required = recipe.energy_required/refineryItemConsumption
	end
	local added = false
	for _,ingredient in pairs(recipe.ingredients) do
		ingredient.fluidbox_index = nil
		if ingredient.name == "water" then
			ingredient.amount = ingredient.amount+wateramt
			added = true
		else
			ingredient.amount = ingredient.amount/refineryItemConsumption
		end
	end
	if not added then
		table.insert(recipe.ingredients, 1, {type="fluid", name="water", amount=wateramt*refineryWasteProductionRatio/refineryItemConsumption})
	end
	
	if data.raw.item["carbon"] then
		table.insert(recipe.ingredients, {"carbon", expensive and 2 or 1})
	else
		--table.insert(recipe.ingredients, {"coal", 2})
	end
	
	if data.raw.item["calcium-chloride"] then
		table.insert(recipe.ingredients, {"calcium-chloride", expensive and 2 or 1})
	end
	
	if data.raw.item["sodium-hydroxide"] then
		table.insert(recipe.ingredients, {"sodium-hydroxide", expensive and 3 or 2})
	end
	
	if data.raw.item["air-filter-case"] then
		table.insert(recipe.ingredients, {type = "item", name = "air-filter", amount = 1, catalyst_amount = 1})
	end
end

if Config.enableRefinery then
	for name,recipe in pairs(data.raw.recipe) do --do later to handle the water->steam conversion some mods do
		if recipe.category == "oil-processing" then
			recipe = table.deepcopy(recipe)
			recipe.category = "clean-oil-processing"
			recipe.name = "clean-" .. name
			recipe.localised_name = {"clean-refining.name", {"recipe-name." .. name}}
			local amt = 0
			local results = recipe.results
			if not results then
				results = recipe.normal.results
			end
			if results then
				for _,result in pairs(results) do
					amt = amt+result.amount
					result.amount = result.amount/refineryItemConsumption
				end
			end
			amt = 5*math.floor((amt/4)/5+0.5)
			
			modifyIngredients(recipe, amt)
			modifyIngredients(recipe.normal, amt, false)
			modifyIngredients(recipe.expensive, amt, true)
			
			table.insert(results, {type="fluid", name="waste", amount=amt*refineryWasteProductionRatio/refineryItemConsumption})
						
			if data.raw.item["air-filter-case"] then
				table.insert(results, {type = "item", name = "air-filter-case", amount = 1, catalyst_amount = 1})
			end
			
			for _,result in pairs(results) do
				result.fluidbox_index = nil
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
	rubber.pollution_absorption_per_second = tile.pollution_absorption_per_second
	rubber.name = name .. "-" .. rubber.name
	rubber.localised_name = "tile-name.rubber-floor"
end

for _,tile in pairs(rubbers) do
	data:extend({
		tile
	})
end
--]]

for name,recipe in pairs(data.raw.recipe) do
	if recipe.category == "void-fluid" then --bob void pump
		local fluid = recipe.ingredients[1].name
		local f = liquidPollutionFactors[fluid]
		if f then
			f = 1+f
			local res = f
			if recipe.emissions_multiplier then
				res = f*recipe.emissions_multiplier
			end
			recipe.emissions_multiplier = res
			log("Setting bob venting of " .. fluid .. " to " .. f .. "x emissions (net " .. res .. ") multiplier")
		end
	end
end

for name,fluid in pairs(data.raw.fluid) do
	for stage = 5,1,-1 do --higher is more fluid
		local radius = 2
		--local stage = 5
		local imgw = 485
		local imgh = 256
		local h = radius
		local w = radius*imgw/imgh
		local clr = table.deepcopy(fluid.base_color)
		local fa = 0.3 --this does not work--> 0.3*stage/5 --0.3
		clr.a = clr.a and clr.a*fa or fa
		--log("Created stage " .. stage .. " with alpha " .. clr.a)
		data:extend(
		  {
			{
			  type = "simple-entity",
			  name = "spilled-" .. name .. "-" .. stage,
			  flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
			  icon = "__NauvisDay__/graphics/icons/spilled-fluid.png",
			  icon_size = 32,
			  subgroup = "spilled-fluid",
			  order = "d[spilled-fluid]-a[" .. name .. "]",
			  selection_box = {{-w, -h}, {w, h}},
			  selectable_in_game = true,
			  collision_mask = {},
			  render_layer = "decorative",
			  localised_name = {"spilled-fluid.name", {"fluid-name." .. name}},
			  pictures =
			  {
				{
				  filename = "__NauvisDay__/graphics/entity/spilled-fluid-" .. stage .. ".png",
				  width = 485,
				  height = 256,
				  scale = 0.5,
				  tint = clr
				}
			  }
			},
		  }
		)
	end
end

-- Scale biter attack pollution
for k,obj in pairs(data.raw["unit"]) do
	obj.pollution_to_join_attack = obj.pollution_to_join_attack*pollutionToJoinAttackScale
end