require "constants"
require "config"

local blurFactor = 5

data:extend({
	{
		type = "recipe-category",
		name = "gas-boiler",
	},
	{
		type = "recipe",
		name = "gas-powered-boiler",
		category = "gas-boiler",
		enabled = "true",
		energy_required = 1.5/blurFactor,
		ingredients = { --default boiler takes about 400 water for 135 steam per coal, slightly faster than 1/s
			{type = "fluid", name = "water", amount = 400/blurFactor},
			{type = "fluid", name = "petroleum-gas", amount = 5/blurFactor},
		},
		results = {
			{type = "fluid", name = "steam", amount = 135/blurFactor},
		},
	}
})

data:extend({
  {
	type = "item",
    name = "gas-boiler",
    icon = "__base__/graphics/icons/boiler.png",
    flags = {"goes-to-quickbar"},
    subgroup = "energy",
    order = "b[gas-boiler]",
    place_result = "gas-boiler",
    stack_size = 50
  },
  {
	type = "recipe",
	name = "gas-boiler",
	energy_required = 1.5,
	ingredients = {
		{"boiler", 1},
		{"pipe", 4},
		{"steel-plate", 5},
		{"advanced-circuit", 1},
	},
	result = "gas-boiler",
  }
})

data:extend({
	 {
    type = "assembling-machine",
    name = "gas-boiler",
    icon = "__base__/graphics/icons/boiler.png",
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "gas-boiler"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    dying_explosion = "medium-explosion",
	resistances =
    {
      {
        type = "fire",
        percent = 90
      },
      {
        type = "explosion",
        percent = 30
      },
      {
        type = "impact",
        percent = 30
      }
    },
    collision_box = {{-1.29, -1.29}, {1.29, 1.29}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},

    animation =
    {
      north =
      { 
        layers = 
        { 
          {
            filename = "__base__/graphics/entity/boiler/boiler-N-idle.png",
            priority = "extra-high",
            width = 131,
            height = 108,
			frame_count = 1,
            shift = util.by_pixel(-0.5, 4),
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-N-idle.png",
              priority = "extra-high",
              width = 269,
              height = 221,
			frame_count = 1,
              shift = util.by_pixel(-1.25, 5.25),
              scale = 0.5
            }
          },
          {
            filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
            priority = "extra-high",
            width = 137,
            height = 82,
			frame_count = 1,
            shift = util.by_pixel(20.5, 9),
            draw_as_shadow = true,
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-N-shadow.png",
              priority = "extra-high",
              width = 274,
              height = 164,
			frame_count = 1,
              scale = 0.5,
              shift = util.by_pixel(20.5, 9),
              draw_as_shadow = true,
            }
          }
        }
      },
      east =
      {
        layers = 
        { 
          {
            filename = "__base__/graphics/entity/boiler/boiler-E-idle.png",
            priority = "extra-high",
            width = 105,
            height = 147,
			frame_count = 1,
            shift = util.by_pixel(-3.5, -0.5),
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-E-idle.png",
              priority = "extra-high",
              width = 216,
              height = 301,
			frame_count = 1,
              shift = util.by_pixel(-3, 1.25),
              scale = 0.5
            }
          },
          {
            filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
            priority = "extra-high",
            width = 92,
            height = 97,
			frame_count = 1,
            shift = util.by_pixel(30, 9.5),
            draw_as_shadow = true,
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-E-shadow.png",
              priority = "extra-high",
              width = 184,
              height = 194,
			frame_count = 1,
              scale = 0.5,
              shift = util.by_pixel(30, 9.5),
              draw_as_shadow = true,
            }
          }
        }
      },
      south =
      {
        layers = 
        { 
          {
            filename = "__base__/graphics/entity/boiler/boiler-S-idle.png",
            priority = "extra-high",
            width = 128,
            height = 95,
			frame_count = 1,
            shift = util.by_pixel(3, 12.5),
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-S-idle.png",
              priority = "extra-high",
              width = 260,
              height = 192,
			frame_count = 1,
              shift = util.by_pixel(4, 13),
              scale = 0.5
            }
          },
          {
            filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
            priority = "extra-high",
            width = 156,
            height = 66,
			frame_count = 1,
            shift = util.by_pixel(30, 16),
            draw_as_shadow = true,
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-S-shadow.png",
              priority = "extra-high",
              width = 311,
              height = 131,
			frame_count = 1,
              scale = 0.5,
              shift = util.by_pixel(29.75, 15.75),
              draw_as_shadow = true,
            }
          }
        }
      },
      west =
      {
        layers = 
        { 
          {
            filename = "__base__/graphics/entity/boiler/boiler-W-idle.png",
            priority = "extra-high",
            width = 96,
            height = 132,
			frame_count = 1,
            shift = util.by_pixel(1, 5),
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-W-idle.png",
              priority = "extra-high",
              width = 196,
              height = 273,
			frame_count = 1,
              shift = util.by_pixel(1.5, 7.75),
              scale = 0.5
            }
          },
          {
            filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
            priority = "extra-high",
            width = 103,
            height = 109,
			frame_count = 1,
            shift = util.by_pixel(19.5, 6.5),
            draw_as_shadow = true,
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-W-shadow.png",
              priority = "extra-high",
              width = 206,
              height = 218,
			frame_count = 1,
              scale = 0.5,
              shift = util.by_pixel(19.5, 6.5),
              draw_as_shadow = true,
            }
          }
        }
      }
    },
    working_visualisations =
    {
      east =
      {
        filename = "__base__/graphics/entity/boiler/boiler-E-patch.png",
        priority = "extra-high",
        width = 3,
        height = 17,
        frame_count = 64,
        shift = util.by_pixel(33.5, -13.5),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-E-patch.png",
          width = 6,
          height = 36,
        frame_count = 64,
          shift = util.by_pixel(33.5, -13.5),
          scale = 0.5
        }
      },
    },
    
    fire_flicker_enabled = true,
    fire =
    {
      north =
      {
        filename = "__base__/graphics/entity/boiler/boiler-N-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 12,
        height = 13,
        animation_speed = 0.5,
        shift = util.by_pixel(0, -8.5),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-N-fire.png",
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 26,
          height = 26,
          animation_speed = 0.5,
          shift = util.by_pixel(0, -8.5),
          scale = 0.5
        }
      },
      east =
      {
        filename = "__base__/graphics/entity/boiler/boiler-E-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 14,
        height = 14,
        animation_speed = 0.5,
        shift = util.by_pixel(-10, -22),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-E-fire.png",
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 28,
          height = 28,
          animation_speed = 0.5,
          shift = util.by_pixel(-9.5, -22),
          scale = 0.5
        }
      },
      south =
      {
        filename = "__base__/graphics/entity/boiler/boiler-S-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 12,
        height = 9,
        animation_speed = 0.5,
        shift = util.by_pixel(-1, -26.5),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-S-fire.png",
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 26,
          height = 16,
          animation_speed = 0.5,
          shift = util.by_pixel(-1, -26.5),
          scale = 0.5
        }
      },
      west =
      {
        filename = "__base__/graphics/entity/boiler/boiler-W-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 14,
        height = 14,
        animation_speed = 0.5,
        shift = util.by_pixel(13, -23),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-W-fire.png",
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 30,
          height = 29,
          animation_speed = 0.5,
          shift = util.by_pixel(13, -23.25),
          scale = 0.5
        }
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/boiler.ogg",
        volume = 0.8
      },
      max_sounds_per_type = 3
    },
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.1 / 6.5 /1.5 --/1.5, which comes to 1/6th when taking the coal 4x into account
    },
    energy_usage = "10kW",
    ingredient_count = 2,
    crafting_categories = {"gas-boiler"},
    fluid_boxes =
    {
      {
		  production_type = "input",
		  base_area = 1,
		  height = 2,
		  base_level = -1,
		  pipe_covers = pipecoverspictures(),
		  pipe_connections =
		  {
			{type = "input", position = {-2, 0.5}},
			{type = "input", position = {2, 0.5}}
		  },
      },
      {
		  production_type = "input",
		  base_area = 1,
		  height = 2,
		  base_level = -1,
		  pipe_covers = pipecoverspictures(),
		  pipe_connections =
		  {
			{type = "input", position = {0, 1.5}}
		  },
      },
      {
		  production_type = "output",
		  base_area = 1,
		  height = 2,
		  base_level = 1,
		  pipe_covers = pipecoverspictures(),
		  pipe_connections =
		  {
			{type = "output", position = {0, -1.5}}
		  },
      }
    }
  }
})