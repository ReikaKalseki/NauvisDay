require "constants"
require "config"

if not Config.enableRefinery then return end

data:extend({{type = "recipe-category", name = "clean-oil-processing"}})

local refinery = table.deepcopy(data.raw["assembling-machine"]["oil-refinery"])
refinery.name = "clean-refinery"
refinery.minable.result = refinery.name
refinery.crafting_categories = {"clean-oil-processing"}
refinery.energy_usage = "520kW"
refinery.ingredient_count = refinery.ingredient_count+1
refinery.energy_source.emissions = refinery.energy_source.emissions*4
refinery.fluid_boxes =
    {
	  --[[
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {2, 3} }}
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
        pipe_connections = {{ position = {-1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        base_level = 1,
        pipe_connections = {{ position = {2, -3} }}
      }--]]
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

local recipe = {
    type = "recipe",
    name = "clean-refinery",
    energy_required = 10,
    ingredients =
    {
      {"oil-refinery", 1},
      {"iron-gear-wheel", 20},
      {"advanced-circuit", 5},
      {"pipe", 25},
	  {"air-filter", 30}
    },
    result = "clean-refinery",
    enabled = false
}

local item = table.deepcopy(data.raw.item["oil-refinery"])
item.name = "clean-refinery"
item.place_result = item.name

data:extend({refinery, item, recipe})
