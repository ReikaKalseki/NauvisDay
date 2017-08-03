require "constants"
require "config"

if not Config.enableSteamFurnace then return end

local power = 1--15

data:extend({
	{
		type = "recipe-category",
		name = "steam-smelting",
	}
})

data:extend({
  {
	type = "item",
    name = "steam-furnace",
    icon = "__NauvisDay__/graphics/icons/steel-furnace.png",
    flags = {"goes-to-quickbar"},
    subgroup = "smelting-machine",
    order = "b[steam-furnace]",
    place_result = "steam-furnace",
    stack_size = 50
  },--[[
  {
	type = "item",
    name = "steam-furnace-flipped",
    icon = "__NauvisDay__/graphics/icons/steel-furnace.png",
    flags = {"goes-to-quickbar"},
    subgroup = "smelting-machine",
    order = "b[steam-furnace]",
    place_result = "steam-furnace-flipped",
    stack_size = 50
  },--]]
  {
	type = "recipe",
	name = "steam-furnace",
	energy_required = 3.5,
	enabled = "false",
	ingredients = {
		{"steel-furnace", 1},
		{"pipe", 10},
		{"stone", 5},
	},
	result = "steam-furnace",
  },--[[
  {
	type = "recipe",
	name = "steam-furnace-flipped",
	energy_required = 0.002,
	enabled = "false",
	ingredients = {
		{"steam-furnace", 1},
	},
	result = "steam-furnace-flipped",
  }--]]
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
    open_sound = nil,
    close_sound = nil,
    working_sound =
    {
      sound = { filename = "__base__/sound/furnace.ogg" },
      idle_sound = nil,
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
			{type = "input", positions = {{0.5, -1.5}, {1.5, -0.5}, {0.5, 1.5}, {-1.5, -0.5}}},
		},
        secondary_draw_orders = { north = -1 }
      },
	},
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-0.8, -1}, {0.8, 1}},
    crafting_categories = {"steam-smelting"},
    result_inventory_size = 1,
    energy_usage = power .. "kW", --both steel and stone use 180kW, but this is now electric power usage; note that pollution is tied to this value
    crafting_speed = 1.5, --stone is 1, steel is 2
    source_inventory_size = 2,
	ingredient_count = 2,
    energy_source =
    {
      type = "burner",
      fuel_category = "chemical",
      effectivity = 1,
      emissions = 0.32*3*15/power, --totals 1/8th of a steel furnace when coal and other multipliers are applied, at 15kW power consumption
      fuel_inventory_size = 0,
      smoke =
      {
        {
          name = "smoke",
          frequency = 10,
          position = {0.7, -1.2},
          starting_vertical_speed = 0.08,
          starting_frame_deviation = 60
        }
      }
    },
    animation =
    {
      layers = {
        {
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace.png",
          priority = "high",
          width = 85,
          height = 87,
          frame_count = 1,
          shift = util.by_pixel(-1.5, 1.5),
          hr_version = {
            filename = "__NauvisDay__/graphics/entity/steam-furnace/hr-steel-furnace.png",
            priority = "high",
            width = 171,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(-1.25, 2),
            scale = 0.5
          }
        },
        {
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace-shadow.png",
          priority = "high",
          width = 139,
          height = 43,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(39.5, 11.5),
          hr_version = {
            filename = "__NauvisDay__/graphics/entity/steam-furnace/hr-steel-furnace-shadow.png",
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
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace-fire.png",
          priority = "high",
          line_length = 8,
          width = 29,
          height = 40,
          frame_count = 48,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(-0.5, 6),
          hr_version = {
            filename = "__NauvisDay__/graphics/entity/steam-furnace/hr-steel-furnace-fire.png",
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
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace-glow.png",
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
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace-working.png",
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
            filename = "__NauvisDay__/graphics/entity/steam-furnace/hr-steel-furnace-working.png",
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
--[[
data:extend({
	  {
    type = "electric-pole",
    name = "furnace-electric-pole",
    --icon = "__base__/graphics/icons/rail-signal.png",
    flags = {"placeable-off-grid", "not-on-map"},
    --fast_replaceable_group = "rail-signal",
    --minable = {mining_time = 0.5, result = "rail-signal"},
    max_health = 100,
	destructible = false,
	selectable_in_game = false,
    corpse = "small-remnants",
    --collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    --selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
    --drawing_box = {{-0.5, -2.6}, {0.5, 0.5}},
    maximum_wire_distance = 0.25,
    supply_area_distance = 0.5,
    vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 },
    track_coverage_during_build_by_moving = false,
    pictures =
    {
      filename = "__NauvisDay__/graphics/entity/furnace-electric-pole.png",
      priority = "extra-high",
      width = 123,
      height = 124,
      direction_count = 4,
      shift = {1.4, -1.1}
    },
    connection_points =
    {
      {
        shadow =
        {
          copper = {2.7, 0},
          red = {2.3, 0},
          green = {3.1, 0}
        },
        wire =
        {
          copper = {0, -2.7},
          red = {-0.375, -2.625},
          green = {0.40625, -2.625}
        }
      },
      {
        shadow =
        {
          copper = {2.7, -0.05},
          red = {2.2, -0.35},
          green = {3, 0.12}
        },
        wire =
        {
          copper = {-0.04, -2.8},
          red = {-0.375, -2.9375},
          green = {0.1875, -2.5625}
        }
      },
      {
        shadow =
        {
          copper = {2.5, -0.1},
          red = {2.55, -0.45},
          green = {2.5, 0.25}
        },
        wire =
        {
          copper = {-0.15625, -2.6875},
          red = {-0.0625, -2.96875},
          green = {-0.03125, -2.40625}
        }
      },
      {
        shadow =
        {
          copper = {2.30, -0.1},
          red = {2.65, -0.40},
          green = {1.75, 0.20}
        },
        wire =
        {
          copper = {-0.03125, -2.71875},
          red = {0.3125, -2.875},
          green = {-0.25, -2.5}
        }
      }
    },
    radius_visualisation_picture =
    {
      filename = "__NauvisDay__/graphics/entity/transparent.png",
      width = 12,
      height = 12,
      priority = "extra-high-no-scale"
    }
  },
 {
    type = "electric-energy-interface",
    name = "furnace-energy-interface",
    --icon = "__base__/graphics/icons/rail-signal.png",
    flags = {"placeable-off-grid", "not-on-map"},
    --fast_replaceable_group = "rail-signal",
    --minable = {mining_time = 0.5, result = "rail-signal"},
    max_health = 100,
	destructible = false,
	selectable_in_game = false,
    corpse = "medium-remnants",
    --collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    --selection_box = {{-1, -1}, {1, 1}},
    energy_source =
    {
      type = "electric",
      buffer_capacity = "100J",
      usage_priority = "terciary",
      input_flow_limit = "0kW",
      output_flow_limit = "100kW"
    },

    energy_production = "100kW",
    energy_usage = "0kW",
    -- also 'pictures' for 4-way sprite is available, or 'animation' resp. 'animations'
    picture =
    {
      filename = "__NauvisDay__/graphics/entity/furnace-energy-interface.png",
      priority = "extra-high",
      width = 124,
      height = 103,
      shift = {0.6875, -0.203125},
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    working_sound = nil
  },
})
--]]