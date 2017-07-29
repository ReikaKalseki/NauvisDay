require "constants"

data:extend(
{
	{
		type = "resource-category",
		name = "borehole"
	},
	{
		type = "resource-category",
		name = "filled-borehole"
	}
})

local well = util.table.deepcopy(data.raw.resource["crude-oil"])
well.name = "borehole"
well.autoplace = nil
well.category = "borehole"
well.map_color = {r=0.25, g=0.25, b=0.25}
well.highlight = false
well.infinite = false
well.minable.required_fluid = "waste"
well.minable.fluid_amount = 100*20*pollutionLiquidProductionFactor
well.minable.mining_time = 30
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
        filename = "__NauvisDay__/graphics/entity/borehole.png",
        priority = "extra-high",
        width = 75,
        height = 61,
        frame_count = 1,
        variation_count = 1
      }
    }
	
local well2 = util.table.deepcopy(well)
well2.name = "used-borehole"
well2.map_color = {r=0.5, g=0.5, b=0.5}
well2.minable.fluid_amount = 100*20*pollutionLiquidProductionFactor
well2.minable.mining_time = 30
well2.stages = 
    {
      sheet =
      {
        filename = "__NauvisDay__/graphics/entity/used-borehole.png",
        priority = "extra-high",
        width = 75,
        height = 61,
        frame_count = 1,
        variation_count = 1
      }
    }
	
local well3 = util.table.deepcopy(well)
well3.name = "filled-borehole"
well3.map_color = {r=0.5, g=0.5, b=0.5}
well3.category = "filled-borehole"
well3.minable.required_fluid = nil
well3.minable.fluid_amount = nil
well3.minable.mining_time = 1
well3.stages = 
    {
      sheet =
      {
        filename = "__NauvisDay__/graphics/entity/filled-borehole.png",
        priority = "extra-high",
        width = 75,
        height = 61,
        frame_count = 1,
        variation_count = 1
      }
    }

data:extend(
{
	well, well2, well3
})