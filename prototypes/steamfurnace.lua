require "constants"
require "config"

data:extend({
	{
		type = "recipe-category",
		name = "steam-smelting",
	}
})

local recipes = {}

for name,recipe in pairs(data.raw.recipe) do
	if recipe.category == "smelting" then
		local copy = table.deepcopy(recipe)
		copy.name = copy.name .. "-steam"
		copy.category = "steam-smelting"
		if copy.ingredients then
			table.insert(copy.ingredients, {type="fluid", name="steam", amount=20})
		end
		if copy.normal and copy.normal.ingredients then
			table.insert(copy.normal.ingredients, {type="fluid", name="steam", amount=20})
		end
		if copy.expensive and copy.expensive.ingredients then
			table.insert(copy.expensive.ingredients, {type="fluid", name="steam", amount=50})
		end
		table.insert(recipes, copy)
	end
end

for _,recipe in pairs(recipes) do
	data:extend({recipe})
end

data:extend({
  {
	type = "item",
    name = "steam-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    flags = {"goes-to-quickbar"},
    subgroup = "smelting-machine",
    order = "b[steam-furnace]",
    place_result = "steam-furnace",
    stack_size = 50
  },
  {
	type = "recipe",
	name = "steam-furnace",
	energy_required = 3.5,
	ingredients = {
		{"steel-furnace", 1},
		{"pipe", 10},
		{"stone", 5},
	},
	result = "steam-furnace",
  }
})

data:extend({
  {
    type = "assembling-machine",
    name = "steam-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "steam-furnace"},
    max_health = 300,
    corpse = "medium-remnants",
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__base__/sound/furnace.ogg" }
    },
    resistances =
    {
      {
        type = "fire",
        percent = 100
      }
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {
			{type = "input", position = {0.5, -1.5}},
		},
        secondary_draw_orders = { north = -1 }
      },
	},
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-0.8, -1}, {0.8, 1}},
    crafting_categories = {"steam-smelting"},
    result_inventory_size = 1,
    energy_usage = "15kW", --both steel and stone use 180kW, but this is now electric power usage
    crafting_speed = 1.5, --stone is 1, steel is 2
    source_inventory_size = 2,
	ingredient_count = 2,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.01 --1/2 as much as a steel furnace, before the 4x coal-burning factor, then the steel-furnace 1.5x, making it total 1/12th
    },
    animation =
    {
      layers = {
        {
          filename = "__base__/graphics/entity/steel-furnace/steel-furnace.png",
          priority = "high",
          width = 85,
          height = 87,
          frame_count = 1,
          shift = util.by_pixel(-1.5, 1.5),
          hr_version = {
            filename = "__base__/graphics/entity/steel-furnace/hr-steel-furnace.png",
            priority = "high",
            width = 171,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(-1.25, 2),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/steel-furnace/steel-furnace-shadow.png",
          priority = "high",
          width = 139,
          height = 43,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(39.5, 11.5),
          hr_version = {
            filename = "__base__/graphics/entity/steel-furnace/hr-steel-furnace-shadow.png",
            priority = "high",
            width = 277,
            height = 85,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(39.25, 11.25),
            scale = 0.5
          }
        },
      },
    },
    working_visualisations =
    {
      {
        north_position = {0.0, 0.0},
        east_position = {0.0, 0.0},
        south_position = {0.0, 0.0},
        west_position = {0.0, 0.0},
        animation =
        {
          filename = "__base__/graphics/entity/steel-furnace/steel-furnace-fire.png",
          priority = "high",
          line_length = 8,
          width = 29,
          height = 40,
          frame_count = 48,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(-0.5, 6),
          hr_version = {
            filename = "__base__/graphics/entity/steel-furnace/hr-steel-furnace-fire.png",
            priority = "high",
            line_length = 8,
            width = 57,
            height = 81,
            frame_count = 48,
            axially_symmetrical = false,
            direction_count = 1,
            shift = util.by_pixel(-0.75, 5.75),
            scale = 0.5
          }
        },
        light = {intensity = 1, size = 1, color = {r = 1.0, g = 1.0, b = 1.0}}
      },
      {
        north_position = {0.0, 0.0},
        east_position = {0.0, 0.0},
        south_position = {0.0, 0.0},
        west_position = {0.0, 0.0},
        effect = "flicker", -- changes alpha based on energy source light intensity
        animation =
        {
          filename = "__base__/graphics/entity/steel-furnace/steel-furnace-glow.png",
          priority = "high",
          width = 60,
          height = 43,
          frame_count = 1,
          shift = {0.03125, 0.640625},
          blend_mode = "additive"
        }
      },
      {
        north_position = {0.0, 0.0},
        east_position = {0.0, 0.0},
        south_position = {0.0, 0.0},
        west_position = {0.0, 0.0},
        effect = "flicker", -- changes alpha based on energy source light intensity
        animation =
        {
          filename = "__base__/graphics/entity/steel-furnace/steel-furnace-working.png",
          priority = "high",
          line_length = 8,
          width = 64,
          height = 75,
          frame_count = 1,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(0, -4.5),
          blend_mode = "additive",
          hr_version = {
            filename = "__base__/graphics/entity/steel-furnace/hr-steel-furnace-working.png",
            priority = "high",
            line_length = 8,
            width = 130,
            height = 149,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            shift = util.by_pixel(0, -4.25),
            blend_mode = "additive",
            scale = 0.5
          }
        }
      },
    },
    fast_replaceable_group = "furnace"
  }
})