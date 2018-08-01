require "config"
require "constants"

if data.raw.item.glass then
	table.insert(data.raw.recipe.greenhouse.ingredients, {"glass", 30})
end

local function createDeadName(name)
	return {"dead-farm.name", {"entity-name." .. name}}
end

if data.raw.resource["crude-oil-sand"] then
	data:extend({{type = "resource-category", name = "oil-fracking"}})

	data.raw.resource["crude-oil-sand"].category = "oil-fracking"
	
	local newpump = table.deepcopy(data.raw["mining-drill"]["pumpjack"])
	newpump.name = "fracking-well"
	newpump.minable.result = "fracking-well"
	newpump.resource_categories = {"oil-fracking"}
	newpump.energy_source.emissions = newpump.energy_source.emissions*9
	
	--[[
	local dirs = {"north", "south", "west", "east"}
	for _,dir in pairs(dirs) do
		newpump.animations[dir].layers[1].filename = "__NauvisDay__/graphics/entity/fracking-well.png"
		newpump.animations[dir].layers[1].hr_version.filename = "__NauvisDay__/graphics/entity/fracking-well.png"
	end
	--]]
	
	local item = table.deepcopy(data.raw.item["pumpjack"])
	item.name = newpump.name
	item.place_result = item.name
	
	local recipe = table.deepcopy(data.raw.recipe["pumpjack"])
	recipe.name = newpump.name
	recipe.result = newpump.name
	
	data:extend({newpump, item, recipe})
	
	table.insert(data.raw.technology["fracking"].effects, {type = "unlock-recipe", recipe = recipe.name})
	
	--Copy his fluidpatch from pumpjack to fracking well
	local fluid_inputs = {}
	for k,v in pairs(data.raw["mining-drill"]["electric-mining-drill"]) do
		if string.find(k, "input_fluid") then
			fluid_inputs[k] = table.deepcopy(v)
		end
	end
	
	if not newpump.input_fluid_box then
		for k, v in pairs(fluid_inputs) do
			newpump[k] = v
		end
	end
end

if data.raw["assembling-machine"]["bi_bio_farm"] then
	local dead = table.deepcopy(data.raw["assembling-machine"]["bi_bio_farm"])
	dead.name = "dead-bio-farm"
	dead.crafting_speed = 0.001
	dead.order = "z"
	dead.energy_source =
    {
      type = "burner",
	  fuel_category = "chemical",
      effectivity = 0.05,
      fuel_inventory_size = 0,
      burnt_inventory_size = 0,
      emissions = 0.03
    }
	dead.animation.filename = "__NauvisDay__/graphics/entity/treefarm/dead-biofarm.png"
	dead.working_visualisations.animation.filename ="__NauvisDay__/graphics/entity/treefarm/dead-biofarm-active.png"
	dead.working_visualisations.light = nil
	dead.localised_name = createDeadName("bi_bio_farm")
	
	data:extend({dead})
end

if data.raw["assembling-machine"]["bob-greenhouse"] then
	local dead = table.deepcopy(data.raw["assembling-machine"]["bob-greenhouse"])
	dead.name = "dead-greenhouse"
	dead.crafting_speed = 0.001
	dead.order = "z"
	dead.energy_source =
    {
      type = "burner",
	  fuel_category = "chemical",
      effectivity = 0.05,
      fuel_inventory_size = 0,
      burnt_inventory_size = 0,
      emissions = 0.03
    }
	dead.animation.filename = "__NauvisDay__/graphics/entity/treefarm/dead-greenhouse.png"
	dead.working_visualisations[1].animation.filename ="__NauvisDay__/graphics/entity/treefarm/dead-greenhouse-active.png"
	dead.working_visualisations[1].light = nil
	dead.animation.width = 113
    dead.animation.height = 91
	dead.working_visualisations[1].width = 113
    dead.working_visualisations[1].height = 91
	
	dead.localised_name = createDeadName("bob-greenhouse")
	
	data:extend({dead})
end

if data.raw.tree["tf-germling"] then
	data:extend({
	{
      type = "simple-entity",
      name = "dead-tf-tree",
      icon = "__base__/graphics/icons/tree-01-stump.png",
      flags = {"placeable-neutral", "not-on-map"},
	  minable = {mining_time = 2, result=nil},
	  collision_box = {{-0.7*0.75, -0.8*0.75}, {0.7*0.75, 0.8*0.75}},
	  selection_box = {{-0.8*0.75, -2.2*0.75}, {0.8*0.75, 0.8*0.75}},
      tile_width = 1,
      tile_height = 1,
      --selectable_in_game = false,
      --time_before_removed = 60 * 60 * 15, -- 15 minutes
      final_render_layer = "object",
      render_layer = "object",
      subgroup = "remnants",
      order="d[remnants]-b[tree]",
	  localised_name = {"entity-name.dead-tree"},
      pictures = {
		{
			filename = "__NauvisDay__/graphics/entity/treefarm/dead-tree-01.png",
			priority = "extra-high",
			width = math.floor(155*0.75),
			height = math.floor(118*0.75),
			shift = {1.1*0.75, -1*0.75},
			frame_count = 1,
			direction_count = 1,
		},
		{
			filename = "__NauvisDay__/graphics/entity/treefarm/dead-tree-05.png",
			priority = "extra-high",
			width = math.floor(156*0.75),
			height = math.floor(154*0.75),
			shift = {1.5*0.75, -1.7*0.75},
			frame_count = 1,
			direction_count = 1,
		},
		{
			filename = "__NauvisDay__/graphics/entity/treefarm/dead-tree-06.png",
			priority = "extra-high",
			width = math.floor(113*0.75),
			height = math.floor(111*0.75),
			shift = {0.7*0.75, -0.9*0.75},
			frame_count = 1,
			direction_count = 1,
		}
	  }
    }
	})
end

if Config.enableSteamFurnace and data.raw.item["stone-pipe"] then
	data:extend({
	  {
		type = "recipe",
		name = "steam-furnace-2",
		energy_required = 3.5,
		enabled = "false",
		ingredients = {
			{"steel-furnace", 1},
			{"stone-pipe", 8},
			{"pipe", 2},
			{"stone", 5},
		},
		result = "steam-furnace",
	  }
	})
	table.insert(data.raw.technology["advanced-material-processing"].effects, {type="unlock-recipe", recipe="steam-furnace-2"})
end

if Config.enableRefinery and data.raw.technology["chemical-processing-2"] then
	table.insert(data.raw.technology["clean-oil-processing"].prerequisites, "chemical-processing-2")
end