require "constants"

require "__DragonIndustries__.registration"
require "__DragonIndustries__.cloning"

data:extend(
{
  {
    type = "fluid",
    name = "waste",
    default_temperature = 20,
    max_temperature = 20,
    heat_capacity = "30J",
    base_color = {r=0.33, g=0.36, b=0.16},
    flow_color = {r=0.46, g=0.48, b=0.36},
    icon = "__NauvisDay__/graphics/icons/sludge.png",
	icon_size = 32,
    order = "a[fluid]-a[waste]",
    pressure_to_speed_ratio = 0.2,
    flow_to_energy_ratio = 0.2,
  },
  {
    type = "fluid",
    name = "polluted-air",
    default_temperature = 20,
    max_temperature = 30,
    heat_capacity = "0J",
    base_color = {r=0.7, g=0.75, b=0.7},
    flow_color = {r=1, g=1, b=1},
    icon = "__NauvisDay__/graphics/icons/air.png",
	icon_size = 32,
    order = "a[fluid]-a[air]",
    pressure_to_speed_ratio = 20,
    flow_to_energy_ratio = 20,
  }
})

data:extend(
{
	{
		type = "resource-category",
		name = "empty-well"
	}
})

local well = util.table.deepcopy(data.raw.resource["crude-oil"])
well.name = Config.depleteWells and "pollution-well" or "tectonic-well"
well.autoplace = nil
well.category = "empty-well"
well.map_color = Config.depleteWells and {r=0.43, g=0.36, b=0.16} or {r=0.1,g=0.1,b=0.1}
well.highlight = (not Config.depleteWells)--false
well.minable.fluid_amount = 20*pollutionLiquidProductionFactor
well.minable.required_fluid = "waste"
--well.infinite_depletion_amount = 0
well.minable.results =
      {
        {
          type = "fluid",
          name = "waste",
          amount_min = 0,
          amount_max = 0,
          probability = 0
        }
      }
well.stages = 
    {
      sheet =
      {
        filename = Config.depleteWells and "__NauvisDay__/graphics/entity/pollution-well.png" or "__NauvisDay__/graphics/entity/tectonic-well.png",
        priority = "extra-high",
        width = Config.depleteWells and 75 or 90,
        height = Config.depleteWells and 61 or 48,
        frame_count = 1,
        variation_count = 1
      }
    }

data:extend(
{
	well,
	   {
		type = "item",
		name = "mined-sludge",
		icon = "__NauvisDay__/graphics/icons/mined-sludge.png",
		flags = {},
		subgroup = "intermediate-product",
		--order = "f[stone-wall]-f[tough-wall-1-2]",
		stack_size = 50,
		icon_size = 32
	  },
	  {
		type = "recipe",
		name = "mined-sludge-liquefaction",
		category = "chemistry",
		--order = "f[plastic-bar]-f[venting]",
		icon = data.raw.fluid["waste"].icon,
		icon_size = data.raw.fluid["waste"].icon_size,
		energy_required = 4,
		enabled = "false",
		subgroup = "fluid",
		ingredients = {
		  {type="item", name="mined-sludge", amount=1},
		  {type="fluid", name="water", amount=20},
		},
		results = {{type="fluid", name="waste", amount=200}},
		crafting_machine_tint =
		{
		  primary = data.raw.fluid["waste"].base_color,
		  secondary = data.raw.fluid["waste"].base_color,
		  tertiary = data.raw.fluid["waste"].base_color,
		  quaternary = data.raw.fluid["waste"].base_color,
		}
	  },
})

local waters = {}
for name,tile in pairs(data.raw.tile) do
	if string.find(name, "water") then
		log("Creating polluted form of " .. name)
		--log("Parsing " .. name)
		local water = table.deepcopy(data.raw.tile.landfill)
		local watername = "polluted-" .. name
		water.name = watername
		water.autoplace = nil
		--log("Inserting " .. name .. " into " .. (water.allowed_neighbors and (#water.allowed_neighbors .. " @ " .. name) or "nil") .. " for " .. watername)
		water.pollution_absorption_per_second=-0.0625---20---0.125 instead of making it emit pollution (net), make it only reduce absorption, but not work for offshore pumps and the like
		water.map_color={r=64, g=77, b=29}
		water.localised_name = {"polluted-fluid.fluid", {"tile-name." .. name}}
		water.collision_mask =
		{
		  --"water-tile", --removing this prevents offshore pumps from being placed on it.....not anymore
		  "item-layer",
		  "resource-layer",
		  "player-layer",
		  "doodad-layer"
		}
		water.name = "polluted-water"
		replaceSpritesDynamic("NauvisDay", "landfill", water)
		water.name = watername
		water.minable = {
			mining_time = 5,
			result = "mined-sludge",
			count = 10,
		}
		water.mined_sound = {filename = "__NauvisDay__/sound/mine-sludge.ogg", volume = 1.5}
		--log(serpent.block(water))
		table.insert(waters, water)
	end
end

registerObjectArray(waters)

local pumps = {}
for name,val in pairs(data.raw["offshore-pump"]) do
	--log("Parsing " .. name)
	local pump = table.deepcopy(val)
	pump.localised_name = {"polluted-fluid.pump", {"entity-name." .. pump.name}}
	pump.name = "polluted-" .. pump.name
	pump.pumping_speed = 1
	pump.fluid_box.base_area = 0.00001
	pump.order="d[remnants]-c[offshore-pump]"
	--log(serpent.block(pump))
	table.insert(pumps, pump)
end

registerObjectArray(pumps)