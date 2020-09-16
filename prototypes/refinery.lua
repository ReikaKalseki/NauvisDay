require "constants"
require "config"

if not Config.enableRefinery then return end

data:extend({{type = "recipe-category", name = "clean-oil-processing"}})

function parseIngredient(entry)
	local type = entry.name and entry.name or entry[1]
	local amt = entry.amount and entry.amount or entry[2]
	return {type, amt}
end

local function createRefinery(base)
	local refinery = table.deepcopy(base)
	refinery.name = "clean-" .. base.name
	refinery.minable.result = refinery.name
	refinery.crafting_categories = {"clean-oil-processing"}
	refinery.localised_name = {"clean-refinery.name", {"entity-name." .. base.name}}
	local pow = string.gsub(refinery.energy_usage, "kW", "")
	pow = string.gsub(pow, "MW", "")
	if type(pow) == "string" then pow = tonumber(pow) end	
	if pow == nil then error(base.name .. " with " .. base.energy_usage) end
	refinery.energy_usage = (pow*1.25) .. (string.find(base.energy_usage, "MW") and "MW" or "kW")
	--refinery.ingredient_count = refinery.ingredient_count+1
	refinery.energy_source.emissions_per_minute = refinery.energy_source.emissions_per_minute*20 --still 10x less than a refinery
	refinery.crafting_speed = refinery.crafting_speed*Config.cleanRefinerySpeed
	refinery.fluid_boxes =
		{	  
		  {
			production_type = "input",
			pipe_covers = pipecoverspictures(),
			base_area = 20,
			base_level = -1,
			pipe_connections = {{ type="input", position = {-3, 0} }}
		  },
		  {
			production_type = "input",
			pipe_covers = pipecoverspictures(),
			base_area = 10,
			base_level = -1,
			pipe_connections = {{ type="input", position = {-1, 3} }}
		  },
		  {
			production_type = "input",
			pipe_covers = pipecoverspictures(),
			base_area = 10,
			base_level = -1,
			pipe_connections = {{ type="input", position = {1, 3} }}
		  },
		  {
			production_type = "output",
			pipe_covers = pipecoverspictures(),
			base_level = 1,
			pipe_connections = {{ position = {-2, -3} }}
		  },
		  {
			production_type = "output",
			pipe_covers = pipecoverspictures(),
			base_level = 1,
			pipe_connections = {{ position = {0, -3} }}
		  },
		  {
			production_type = "output",
			pipe_covers = pipecoverspictures(),
			base_level = 1,
			pipe_connections = {{ position = {2, -3} }}
		  },
		  {
			production_type = "output",
			pipe_covers = pipecoverspictures(),
			base_level = 1,
			pipe_connections = {{ position = {3, 0} }}
		  }
		}

	local recipe1 = {
		type = "recipe",
		name = refinery.name .. "-conversion",
		energy_required = 10,
		localised_name = {"clean-refinery.conversion", {"entity-name." .. base.name}, refinery.localised_name},
		ingredients =
		{
		  {base.name, 1},
		  {"iron-gear-wheel", 20},
		  {"advanced-circuit", 6},
		  --{"plastic-bar", 15}, --this is in the adv circuit
		  {"pipe", 25},
		  --{"air-filter", 30}
		},
		result = refinery.name,
		enabled = false
	}

	local recipe2 = nil
	if base.name ~= "oil-refinery" then
		local pre = nil
		recipe2 = table.deepcopy(data.raw.recipe[base.name])
		recipe2.name = refinery.name .. "-upgrade"
		for _,ing in pairs(recipe2.ingredients) do
			ing = parseIngredient(ing)
			if ing[1] and string.find(ing[1], "refinery") then
				ing[1] = "clean-" .. ing[1]
				pre = ing[1]
			end
		end
		recipe2.result = refinery.name
		recipe2.enabled = false
		recipe2.localised_name = {"clean-refinery.upgrade", data.raw.item[pre].localised_name, refinery.localised_name}
	end

	local item = table.deepcopy(data.raw.item[base.name])
	item.name = refinery.name
	item.place_result = item.name
	item.localised_name = refinery.localised_name
	
	log("Adding clean refinery " .. refinery.name .. " from " .. base.name .. " " .. (recipe1 and "Conversion" or "-") .. "/" .. (recipe2 and "Upgrade" or "-"))

	data:extend({refinery, item})
	if recipe1 then data:extend({recipe1}) end
	if recipe2 then data:extend({recipe2}) end
end

--createRefinery(data.raw["assembling-machine"]["oil-refinery"])

local function isValidRefinery(name, refinery)
	if string.find(name, "^oil%-refinery%-MS%-%d+$") then
		return false
	end
	return true
end

for name,refinery in pairs(data.raw["assembling-machine"]) do
	if #refinery.crafting_categories == 1 and refinery.crafting_categories[1] == "oil-processing" and isValidRefinery(name, refinery) then
		createRefinery(refinery)
	end
end
