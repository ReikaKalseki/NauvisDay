require "config"
require "constants"

--[[
data.raw["map-settings"]["map-settings"].pollution.diffusion_ratio = 0.05--0.25--0.1 --default is 0.02
data.raw["map-settings"]["map-settings"].pollution.min_to_diffuse = 5 --default is 15
data.raw["map-settings"]["map-settings"].pollution.ageing = 2--want to increase this actually, to discourage paving--0.05--0.25 --default is 1
data.raw["map-settings"]["map-settings"].min_to_show_per_chunk = 200 --default is 700

data.raw["map-settings"]["map-settings"].enemy_evolution.time_factor = -0.00003--0 --default is 0.000004
data.raw["map-settings"]["map-settings"].enemy_evolution.destroy_factor = 0.005 --default is 0.002
data.raw["map-settings"]["map-settings"].enemy_evolution.pollution_factor = data.raw["map-settings"]["map-settings"].enemy_evolution.pollution_factor/pollutionScale*pollutionSpawnIncrease/1.25 --/1.5 to account for dramatic pollution increase
--]]
for category, params in pairs(pollutionAndEvo) do
	for entry, val in pairs(params) do
		data.raw["map-settings"]["map-settings"][category][entry] = val
	end
end

local repl = {}
for _,name in pairs(pollutionIncreaseExclusion) do
	repl[name] = 1
end
pollutionIncreaseExclusion = repl --turn into table for fast lookup

local coalBurners = {"boiler", "furnace", "mining-drill"}--, "inserter", "car", "locomotive"} these do not have emissions params; do they even pollute? (reddit says no)
for idx,label in pairs(coalBurners) do
	for k,obj in pairs(data.raw[label]) do
		if pollutionIncreaseExclusion[k] ~= 1 then
			--log(serpent.block("Checking candidate coal burner '" .. k .. "'"))
			if obj.energy_source.type == "burner" and obj.energy_source.fuel_category == "chemical" then
				--log(serpent.block("ID'ed coal burner '" .. k .. "', increasing emissions " .. coalPollutionScale .. "x"))
				if obj.energy_source.emissions then
					obj.energy_source.emissions = obj.energy_source.emissions*coalPollutionScale
					--log(serpent.block("Success"))
				else
					--log(serpent.block("Entity had no emissions parameter. Entity: "))
					--log(serpent.block(obj))
				end
			end
		end
	end
end

for name,tree in pairs(data.raw["tree"]) do
	if not string.find(name, "dead") then
		--log(serpent.block("Checking candidate coal burner '" .. k .. "'"))
		--log(serpent.block("ID'ed coal burner '" .. k .. "', increasing emissions " .. pollutionScale*coalPollutionScale .. "x"))
		tree.emissions_per_tick = tree.emissions_per_tick*10
	end
end

data.raw.recipe["firearm-magazine"].ingredients = {{"iron-plate", 3}} -- go from 4 plates to 1.5 plates each
data.raw.recipe["firearm-magazine"].result_count = 2 --since attacks are going to be VERY frequent and early game resources are at a premium; since this ammo is obsoleted rapidly, does not affect mid to late game

data.raw.unit["small-biter"].pollution_to_join_attack = 500 --was 200, then 400
--[[
data.raw.unit["small-biter"].max_health = 10 --was 15
data.raw.unit["small-biter"].attack_parameters.ammo_type = make_unit_melee_ammo_type(5) --was 7
--]]

local function getExtraPollution(label, name)
	if extraPollution[label] then
		if extraPollution[label][name] then
			return extraPollution[label][name]
		end
		if extraPollution[label]["*"] then
			return extraPollution[label]["*"]
		end
		if extraPollution[label]["HAS_WILDCARD"] then
			for card,value in pairs(extraPollution[label]) do
				if string.find(card, "_*", 1, true) then
					local look = string.sub(card, 1, -3)
					if string.find(name, look) then
						return value
					end
				end
			end
		end
	end
	return nil
end

local polluters = {"assembling-machine", "pump", "mining-drill", "furnace", "boiler"} --assembly also includes chem plant, refinery, centrifuge
for idx,label in pairs(polluters) do
	for k,obj in pairs(data.raw[label]) do
		if pollutionIncreaseExclusion[k] ~= 1 then
			--log(serpent.block("Checking candidate polluter '" .. k .. "'"))
			--log(serpent.block("ID'ed polluter '" .. k .. "', increasing emissions " .. pollutionScale .. "x"))
			if obj.energy_source.emissions then
				obj.energy_source.emissions = obj.energy_source.emissions*pollutionScale
				if label == "mining-drill" then
					obj.energy_source.emissions = obj.energy_source.emissions*miningPollutionScale
					--log(serpent.block("ID'ed mining polluter '" .. k .. "', increasing emissions again " .. miningPollutionScale .. "x"))
				end
				--log(serpent.block(extraPollution[label]))
				local f = getExtraPollution(label, k)
				if f then
					obj.energy_source.emissions = obj.energy_source.emissions*f
					--log(serpent.block("ID'ed 'extra' polluter '" .. k .. "', increasing emissions again " .. f .. "x"))
				end
				--log(serpent.block("Success"))
			else
				--log(serpent.block("Entity had no emissions parameter. Entity: "))
				--log(serpent.block(obj))
			end
		end
	end
end

for k,obj in pairs(data.raw.fire) do
	--log(serpent.block("Checking candidate polluter '" .. k .. "'"))
	--log(serpent.block("ID'ed polluter '" .. k .. "', increasing emissions " .. pollutionScale*firePollutionScale .. "x"))
	obj.emissions_per_tick = obj.emissions_per_tick*pollutionScale*firePollutionScale
	--log(serpent.block("Success"))
end

table.insert(data.raw.technology["circuit-network"].effects, {type="unlock-recipe", recipe="pollution-detector"})
if Config.enableGasBoiler then
	table.insert(data.raw.technology["advanced-electronics"].effects, {type="unlock-recipe", recipe="gas-boiler"})
end
if Config.enableSteamFurnace then
	table.insert(data.raw.technology["advanced-material-processing"].effects, {type="unlock-recipe", recipe="steam-furnace"})
end

if data.raw.item.glass then
	table.insert(data.raw.recipe.greenhouse.ingredients, {"glass", 30})
end

local function createDeadName(name)
	return {"dead-farm.name", {"entity-name." .. name}}
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

data:extend(
  {
    {
      type = "item-subgroup",
      name = "spilled-fluid",
      group = "environment",
      order = "d",
    },
  }
)

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
          subgroup = "spilled-fluid",
          order = "d[spilled-fluid]-a[" .. name .. "]",
          selection_box = {{-w, -h}, {w, h}},
          selectable_in_game = true,
		  collision_mask = {},
          render_layer = "decorative",
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