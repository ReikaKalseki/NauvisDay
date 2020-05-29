require "constants"

require "__DragonIndustries__.registration"

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
	well
})

local waters = {}
for name,tile in pairs(data.raw.tile) do
	if string.find(name, "water") then
		--log("Parsing " .. name)
		local water = util.table.deepcopy(tile)
		water.name = "polluted-" .. water.name
		water.autoplace = nil
		--log("Inserting " .. name .. " into " .. (water.allowed_neighbors and (#water.allowed_neighbors .. " @ " .. name) or "nil") .. " for " .. water.name)
		if not water.allowed_neighbors then water.allowed_neighbors = {} end
		table.insert(water.allowed_neighbors, name)
		water.pollution_absorption_per_second=-0.0625---20---0.125 instead of making it emit pollution (net), make it only reduce absorption, but not work for offshore pumps and the like
		water.map_color={r=64, g=77, b=29}
		water.localised_name = {"polluted-fluid.fluid", {"tile-name." .. water.name}}
		water.collision_mask =
		{
		  --"water-tile", --removing this prevents offshore pumps from being placed on it.....not anymore
		  "item-layer",
		  "resource-layer",
		  "player-layer",
		  "doodad-layer"
		}
		
		water.variants = tile_variations_template(
		"__NauvisDay__/graphics/terrain/polluted-water/base.png", "__base__/graphics/terrain/masks/transition-1.png",
		"__NauvisDay__/graphics/terrain/polluted-water/hr.png", "__base__/graphics/terrain/masks/hr-transition-1.png",
		{
			max_size = 4,
			[1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
			[2] = { probability = 1, weights = {0.070, 0.070, 0.025, 0.070, 0.070, 0.070, 0.007, 0.025, 0.070, 0.050, 0.015, 0.026, 0.030, 0.005, 0.070, 0.027 }, },
			[4] = { probability = 1.00, weights = {0.070, 0.070, 0.070, 0.070, 0.070, 0.070, 0.015, 0.070, 0.070, 0.070, 0.015, 0.050, 0.070, 0.070, 0.065, 0.070 }, },
			-- [8] = { probability = 1.00, weights = {0.090, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.025, 0.125, 0.005, 0.010, 0.100, 0.100, 0.010, 0.020, 0.020} }
		  }
		)
			
		--log(serpent.block(water))
		table.insert(waters, water)
	end
end

registerObjectArray(waters)

local pumps = {}
for name,val in pairs(data.raw["offshore-pump"]) do
	--log("Parsing " .. name)
	local pump = util.table.deepcopy(val)
	pump.localised_name = {"polluted-fluid.pump", {"entity-name." .. pump.name}}
	pump.name = "polluted-" .. pump.name
	pump.pumping_speed = 1
	pump.fluid_box.base_area = 0.00001
	pump.order="d[remnants]-c[offshore-pump]"
	--log(serpent.block(pump))
	table.insert(pumps, pump)
end

registerObjectArray(pumps)