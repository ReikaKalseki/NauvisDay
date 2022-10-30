require "config"
require "constants"
require "modinterface"

require "prototypes.airfilter"
require "prototypes.refinery"
require "prototypes.tech2"

require "pollution-values"

for category, params in pairs(pollutionAndEvo) do
	for entry, val in pairs(params) do
		if type(val) == "table" then
			val = val[1]
		end
		data.raw["map-settings"]["map-settings"][category][entry] = val
	end
end

data.raw.recipe["firearm-magazine"].ingredients = {{"iron-plate", 3}} -- go from 4 plates to 1.5 plates each
data.raw.recipe["firearm-magazine"].result_count = 2 --since attacks are going to be VERY frequent and early game resources are at a premium; since this ammo is obsoleted rapidly, does not affect mid to late game

data.raw.unit["small-biter"].pollution_to_join_attack = 660 --was 200, then 400, then 500
data.raw.unit["small-biter"].max_health = 12 --was 15
data.raw.unit["small-biter"].attack_parameters.ammo_type = make_unit_melee_ammo_type(6) --was 7

--make it competitive with the gas boiler, which burns 2 units of fuel per second, for vanilla steam amounts (2x fluid_usage_per_tick of 0.5, gen of 900kW each) -> 60steam/sec for 1.8MW
--or 900kW per gas per second
--diesel gens 2MW, but burns 8/60 = 0.133 fuel/tick = 8 units per second, which given the fact it takes 4 units of input to make 3 of diesel (2petrol/2light), means 10.67 units of liquid per second
--or 187kW per fuel per second
---so, raise the power output 80% to 3.6MW and cut fuel use by 3.6, meaning 6.4x fuel efficiency, or 1200kW per gas per second (needs to be more than gas boiler, since a lot more intensive)
if data.raw.generator["petroleum-generator"] then
	data.raw.generator["petroleum-generator"].fluid_usage_per_tick = data.raw.generator["petroleum-generator"].fluid_usage_per_tick/3.6
	data.raw.generator["petroleum-generator"].effectivity = data.raw.generator["petroleum-generator"].effectivity*2.16
end

data.raw.fluid["petroleum-gas"].fuel_value = "1.5MJ"

increaseEmissionValues()

table.insert(data.raw.technology["circuit-network"].effects, {type="unlock-recipe", recipe="pollution-detector"})
if Config.enableGasBoiler then
	table.insert(data.raw.technology["advanced-electronics"].effects, {type="unlock-recipe", recipe="gas-boiler"})
end
if Config.enableSteamFurnace then
	local tech = "advanced-material-processing"--mods["EarlyExtensions"] and "steam-power" or "advanced-material-processing"
	table.insert(data.raw.technology[tech].effects, {type="unlock-recipe", recipe="steam-furnace"})
	table.insert(data.raw.technology[tech].effects, {type="unlock-recipe", recipe="steam-furnace-uncraft"})
	table.insert(data.raw.technology[tech].effects, {type="unlock-recipe", recipe="stone-to-steam-furnace"})
	table.insert(data.raw.technology["advanced-material-processing-2"].effects, {type="unlock-recipe", recipe="steam-furnace-upcraft"})
	if data.raw.technology["chemical-steel-furnace"] then
		table.insert(data.raw.technology["chemical-steel-furnace"].effects, {type="unlock-recipe", recipe="chemical-steam-furnace"})
		table.insert(data.raw.technology["chemical-steel-furnace"].effects, {type="unlock-recipe", recipe="chemical-steam-furnace-uncraft"})
		table.insert(data.raw.technology["electric-chemical-furnace"].effects, {type="unlock-recipe", recipe="chemical-steam-furnace-upcraft"})
	end
	if data.raw.technology["mixing-steel-furnace"] then
		table.insert(data.raw.technology["mixing-steel-furnace"].effects, {type="unlock-recipe", recipe="mixing-steam-furnace"})
		table.insert(data.raw.technology["mixing-steel-furnace"].effects, {type="unlock-recipe", recipe="mixing-steam-furnace-uncraft"})
		table.insert(data.raw.technology["electric-mixing-furnace"].effects, {type="unlock-recipe", recipe="mixing-steam-furnace-upcraft"})
	end
end

local rec = createConversionRecipe("venting-machine", "air-filter-machine-1", false, nil, true)
rec.enabled = false
data:extend({rec})
table.insert(data.raw.technology["pollution-capture"].effects, {type="unlock-recipe", recipe=rec.name})

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