require "config"
require "constants"
require "modinterface"

require "prototypes.airfilter"

for category, params in pairs(pollutionAndEvo) do
	for entry, val in pairs(params) do
		if type(val) == "table" then
			val = val[1]
		end
		data.raw["map-settings"]["map-settings"][category][entry] = val
	end
end

local repl = {}
for _,name in pairs(pollutionIncreaseExclusion) do
	repl[name] = 1
end
pollutionIncreaseExclusion = repl --turn into table for fast lookup

local coalBurners = {"boiler", "furnace", "mining-drill", "assembling-machine"}--, "inserter", "car", "locomotive"} these do not have emissions params; do they even pollute? (reddit says no)
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
	if tree.emissions_per_tick and not string.find(name, "dead") then
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

--make it competitive with the gas boiler, which burns 2 units of fuel per second, for vanilla steam amounts (2x fluid_usage_per_tick of 0.5, gen of 900kW each) -> 60steam/sec for 1.8MW
--or 900kW per gas per second
--diesel gens 2MW, but burns 8/60 = 0.133 fuel/tick = 8 units per second, which given the fact it takes 4 units of input to make 3 of diesel (2petrol/2light), means 10.67 units of liquid per second
--or 187kW per fuel per second
---so, raise the power output 80% to 3.6MW and cut fuel use by 3.6, meaning 6.4x fuel efficiency, or 1200kW per gas per second (needs to be more than gas boiler, since a lot more intensive)
if data.raw.generator["petroleum-generator"] then
	data.raw.generator["petroleum-generator"].fluid_usage_per_tick = data.raw.generator["petroleum-generator"].fluid_usage_per_tick/3.6
	data.raw.generator["petroleum-generator"].effectivity = data.raw.generator["petroleum-generator"].effectivity*2.16
end

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
					--log("Looking for '" .. look .. "' in '" .. name .. "'")
					if string.find(name, look, 1, true) then
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
			log(serpent.block("ID'ed polluter '" .. k .. "', increasing emissions " .. pollutionScale .. "x"))
			if obj.energy_source.emissions then
				obj.energy_source.emissions = obj.energy_source.emissions*pollutionScale
				if label == "mining-drill" then
					obj.energy_source.emissions = obj.energy_source.emissions*miningPollutionScale
					log(serpent.block("ID'ed mining polluter '" .. k .. "', increasing emissions again " .. miningPollutionScale .. "x"))
				end
				--log(serpent.block(extraPollution[label]))
				local f = getExtraPollution(label, k)
				if f then
					obj.energy_source.emissions = obj.energy_source.emissions*f
					log(serpent.block("ID'ed 'extra' polluter '" .. k .. "', increasing emissions again " .. f .. "x"))
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
	if obj.emissions_per_tick then
		obj.emissions_per_tick = obj.emissions_per_tick*pollutionScale*firePollutionScale
	end
	--log(serpent.block("Success"))
end

table.insert(data.raw.technology["circuit-network"].effects, {type="unlock-recipe", recipe="pollution-detector"})
if Config.enableGasBoiler then
	table.insert(data.raw.technology["advanced-electronics"].effects, {type="unlock-recipe", recipe="gas-boiler"})
end
if Config.enableSteamFurnace then
	table.insert(data.raw.technology["advanced-material-processing"].effects, {type="unlock-recipe", recipe="steam-furnace"})
	if data.raw.technology["chemical-processing-2"] then
		table.insert(data.raw.technology["chemical-processing-2"].effects, {type="unlock-recipe", recipe="chemical-steam-furnace"})
	end
	if data.raw.technology["mixing-steel-furnace"] then
		table.insert(data.raw.technology["mixing-steel-furnace"].effects, {type="unlock-recipe", recipe="mixing-steam-furnace"})
	end
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