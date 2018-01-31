require "config"
require "constants"
require "modinterface"

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