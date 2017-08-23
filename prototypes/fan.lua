data:extend({--[[
	{
		type = "resource-category",
		name = "pollution-fan"
	},
	{
	    type = "resource",
		name = "fan-ore",
		icon = "__NauvisDay__/graphics/icons/fan.png",
		flags = {"placeable-neutral"},
		order="a-b-a",
		minable = {
			  hardness = 0.5,
			  mining_time = 10,
			  result = nil
		},
		category = "pollution-fan",
		infinite = true,
		minimum = 100,
		normal = 1000,
		infinite_depletion_amount = 10,
		selectable_in_game = false,
		collision_box = {{ -0.1, -0.1}, {0.1, 0.1}},
		selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
		autoplace = nil,
		stage_counts = {1},
		stages =
		{
		  sheet =
		  {
			filename = "__core__/graphics/empty.png",
			priority = "extra-high",
			width = 1,
			height = 1,
			frame_count = 1,
			variation_count = 1,
		  }
		},
		map_color = {r=0.2,g=0.2,b=1}
	},
	{
		type = "constant-combinator",
		name = "pollution-fan-placer",
		icon = "__NauvisDay__/graphics/icons/fan.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.75, result = "pollution-fan-placer"},
		max_health = 200,
		corpse = "small-remnants",
		selectable_in_game = false,

		collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},

		item_slot_count = 1,

		sprites =
		{
		  north = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  east = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  south = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  west = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  }
		},

		activity_led_sprites = {
		  north = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  east = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  south = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  west = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  }
		},

		activity_led_light = nil,

		activity_led_light_offsets =
		{
		  {0.296875, -0.40625},
		  {0.25, -0.03125},
		  {-0.296875, -0.078125},
		  {-0.21875, -0.46875}
		},

		circuit_wire_connection_points = {
		  {
			shadow = {
			  red = {0.15625, -0.28125},
			  green = {0.65625, -0.25}
			},
			wire = {
			  red = {-0.28125, -0.5625},
			  green = {0.21875, -0.5625},
			}
		  },
		  {
			shadow = {
			  red = {0.75, -0.15625},
			  green = {0.75, 0.25},
			},
			wire = {
			  red = {0.46875, -0.5},
			  green = {0.46875, -0.09375},
			}
		  },
		  {
			shadow = {
			  red = {0.75, 0.5625},
			  green = {0.21875, 0.5625}
			},
			wire = {
			  red = {0.28125, 0.15625},
			  green = {-0.21875, 0.15625}
			}
		  },
		  {
			shadow = {
			  red = {-0.03125, 0.28125},
			  green = {-0.03125, -0.125},
			},
			wire = {
			  red = {-0.46875, 0},
			  green = {-0.46875, -0.40625},
			}
		  }
		},

		circuit_wire_max_distance = 0.1
	},
	{
		type = "mining-drill",
		name = "pollution-fan",
		order = "z",
		icon = "__NauvisDay__/graphics/icons/fan.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 1, result = "pollution-fan-placer"},
		--max_health = 100,
		--selectable_in_game = false,
		destructible = false,
		collision_mask = {},
		resource_categories = {"pollution-fan"},
		corpse = "big-remnants",
		collision_box = {{ -1.4, -1.4}, {1.4, 1.4}},
		selection_box = {{ -1.5, -1.5}, {1.5, 1.5}},
		input_fluid_box = nil,    
		working_sound = {
		  sound = {
			filename = "__NauvisDay__/sound/fan.ogg",
			volume = 0.75
		  },
		  apparent_volume = 1.5,
		},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		animations = {
		  north = {
			priority = "extra-high",
			filename = "__NauvisDay__/graphics/entity/fan/north.png",
			width = 130,
			height = 208,
			line_length = 4,
			frame_count = 8,
			animation_speed = 1,
			shift = {0, 0},
			scale = 4/5,
		  },
		  east = {
			priority = "extra-high",
			filename = "__NauvisDay__/graphics/entity/fan/east.png",
			width = 100,
			height = 110,
			line_length = 1,
			frame_count = 1,
			animation_speed = 1,
			shift = {0, 0},
			scale = 4/5,
		  },
		  south = {
			priority = "extra-high",
			filename = "__NauvisDay__/graphics/entity/fan/south.png",
			width = 130,
			height = 208,
			line_length = 4,
			frame_count = 8,
			animation_speed = 1,
			shift = {0, 0},
			scale = 4/5,
		  },
		  west = {
			priority = "extra-high",
			filename = "__NauvisDay__/graphics/entity/fan/west.png",
			width = 100,
			height = 110,
			line_length = 1,
			frame_count = 1,
			animation_speed = 1,
			shift = {0, 0},
			scale = 4/5,
		  }
		},
		shadow_animations = nil,
		
		mining_speed = 0.5,
		energy_source =
		{
		  type = "electric",
		  emissions = 0,
		  usage_priority = "secondary-input"
		},
		energy_usage = "120kW",
		mining_power = 1,
		resource_searching_radius = 5,
		vector_to_place_result = {0, -10000},
		module_specification = {
		  module_slots = 0
		},
		radius_visualisation_picture =
		{
		  filename = "__core__/graphics/empty.png",
		  width = 1,
		  height = 1
		},
		monitor_visualization_tint = {r=0, g=0, b=0},
		circuit_wire_connection_points =
		{
		  get_circuit_connector_wire_shifting_for_connector({-0.09375, -1.65625}, {-0.09375, -1.65625}, 4),
		  get_circuit_connector_wire_shifting_for_connector({1.28125, -0.40625},  {1.28125, -0.40625},  2),
		  get_circuit_connector_wire_shifting_for_connector({0.09375, 1},         {0.09375, 1},         0),
		  get_circuit_connector_wire_shifting_for_connector({-1.3125, -0.3125},   {-1.3125, -0.3125},   6)
		},
		circuit_connector_sprites =
		{
		  get_circuit_connector_sprites({-0.09375, -1.65625}, {-0.09375, -1.65625}, 4),
		  get_circuit_connector_sprites({1.28125, -0.40625},  {1.28125, -0.40625},  2),
		  get_circuit_connector_sprites({0.09375, 1},         {0.09375, 1},         0),
		  get_circuit_connector_sprites({-1.3125, -0.3125},   {-1.3125, -0.3125},   6)
		},
		circuit_wire_max_distance = 12,
	},--]]
	{
		type = "pump",
		name = "pollution-fan",
		icon = "__NauvisDay__/graphics/icons/fan.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 1, result = "pollution-fan"},
		max_health = 180,
		corpse = "big-remnants",
		collision_box = {{-1.29, -1.29}, {1.29, 1.29}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		dying_explosion = "medium-explosion",
		resistances =
		{
		  {
			type = "fire",
			percent = 90
		  }
		},
		fluid_box =
		{
		  base_area = 1,
		  height = 1,
		  pipe_covers = nil,--pipecoverspictures(),
		  pipe_connections =
		  {
			{ position = {0, -2}, type="output" },
			{ position = {0, 2}, type="input" },
		  },
		},
		energy_source =
		{
		  type = "electric",
		  usage_priority = "secondary-input",
		  emissions = 0,
		},
		energy_usage = "120kW",
		working_sound = nil--[[{
		  sound = {
			filename = "__NauvisDay__/sound/fan.ogg",
			volume = 0.625
		  },
		  apparent_volume = 1.5,
		}--]],
		pumping_speed = 0.1,
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },

		animations =
		{
		  north =
		  {
			filename = "__NauvisDay__/graphics/entity/fan/north.png",
			width = 130,
			height = 208,
			line_length = 4,
			frame_count = 8,
			animation_speed = 1.25,
			shift = {0, 0},
			scale = 4/5,
		  },
		  south =
		  {
			filename = "__NauvisDay__/graphics/entity/fan/south.png",
			width = 130,
			height = 208,
			line_length = 4,
			frame_count = 8,
			animation_speed = 1.25,
			shift = {0, 0},
			scale = 4/5,
		  },
		  west =
		  {
			filename = "__NauvisDay__/graphics/entity/fan/west.png",
			width = 100,
			height = 110,
			line_length = 1,
			frame_count = 1,
			animation_speed = 1.25,
			shift = {0, 0},
			scale = 4/5,
		  },
		  east =
		  {
			filename = "__NauvisDay__/graphics/entity/fan/east.png",
			width = 100,
			height = 110,
			line_length = 1,
			frame_count = 1,
			animation_speed = 1.25,
			shift = {0, 0},
			scale = 4/5,
		  },
		},

		fluid_wagon_connector_frame_count = 1,
		fluid_wagon_connector_graphics = nil,

		fluid_animation =
		{
		  north =
		  {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },

		  east =
		  {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },

		  south =
		  {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  west =
		  {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  }
		},

		glass_pictures =
		{
		  north = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  east = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  south = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  },
		  west = {
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1,
			frame_count = 1,
		  }
		},

		circuit_wire_connection_points =
		{
		  {
			shadow =
			{
			  red = {0.171875, 0.140625},
			  green = {0.171875, 0.265625},
			},
			wire =
			{
			  red = {-0.53125, -0.15625},
			  green = {-0.53125, 0},
			}
		  },
		  {
			shadow =
			{
			  red = {0.890625, 0.703125},
			  green = {0.75, 0.75},
			},
			wire =
			{
			  red = {0.34375, 0.28125},
			  green = {0.34375, 0.4375},
			}
		  },
		  {
			shadow =
			{
			  red = {0.15625, 0.0625},
			  green = {0.09375, 0.125},
			},
			wire =
			{
			  red = {-0.53125, -0.09375},
			  green = {-0.53125, 0.03125},
			}
		  },
		  {
			shadow =
			{
			  red = {0.796875, 0.703125},
			  green = {0.625, 0.75},
			},
			wire =
			{
			  red = {0.40625, 0.28125},
			  green = {0.40625, 0.4375},
			}
		  }
		},
		circuit_connector_sprites =
		{
		  get_circuit_connector_sprites({-0.40625, -0.3125}, nil, 24),
		  get_circuit_connector_sprites({0.125, 0.21875}, {0.34375, 0.40625}, 18),
		  get_circuit_connector_sprites({-0.40625, -0.25}, nil, 24),
		  get_circuit_connector_sprites({0.203125, 0.203125}, {0.25, 0.40625}, 18),
		},
		circuit_wire_max_distance = 12
	},
	{
		type = "storage-tank",
		name = "pollution-fan-tank",
		icon = "__base__/graphics/icons/storage-tank.png",
		flags = {"placeable-player", "player-creation"},
		--minable = {mining_time = 1.5, result = "storage-tank"},
		selectable_in_game = false,
		destructible = false,
		collision_mask = {},
		--corpse = "medium-remnants",
		order = "z",
		collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fluid_box =
		{
		  base_area = 10,
		  pipe_covers = nil,--pipecoverspictures(),
		  pipe_connections =
		  {
			{position = {-0, -1}},
		  },
		},
		window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
		pictures =
		{
		  picture =
		  {
			sheet =
			{
			  filename = "__core__/graphics/empty.png",
			  frames = 1,
			  frame_count = 1,
			  width = 1,
			  height = 1,
			}
		  },
		  fluid_background =
		  {
			  filename = "__core__/graphics/empty.png",
			  frames = 1,
			  frame_count = 1,
			  width = 1,
			  height = 1,
		  },
		  window_background =
		  {
			  filename = "__core__/graphics/empty.png",
			  frames = 1,
			  frame_count = 1,
			  width = 1,
			  height = 1,
		  },
		  flow_sprite =
		  {
			  filename = "__core__/graphics/empty.png",
			  frames = 1,
			  frame_count = 1,
			  width = 1,
			  height = 1,
		  },
		  gas_flow =
		  {
			  filename = "__core__/graphics/empty.png",
			  frames = 1,
			  frame_count = 1,
			  width = 1,
			  height = 1,
		  }
		},
		flow_length_in_ticks = 360,
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		working_sound = nil,
		circuit_wire_connection_points =
		{
		  {
			shadow =
			{
			  red = {2.35938, 0.890625},
			  green = {2.29688, 0.953125},
			},
			wire =
			{
			  red = {-0.40625, -0.375},
			  green = {-0.53125, -0.46875},
			}
		  },
		  {
			shadow =
			{
			  red = {2.35938, 0.890625},
			  green = {2.29688, 0.953125},
			},
			wire =
			{
			  red = {0.46875, -0.53125},
			  green = {0.375, -0.4375},
			}
		  },
		  {
			shadow =
			{
			  red = {2.35938, 0.890625},
			  green = {2.29688, 0.953125},
			},
			wire =
			{
			  red = {-0.40625, -0.375},
			  green = {-0.53125, -0.46875},
			}
		  },
		  {
			shadow =
			{
			  red = {2.35938, 0.890625},
			  green = {2.29688, 0.953125},
			},
			wire =
			{
			  red = {0.46875, -0.53125},
			  green = {0.375, -0.4375},
			}
		  },
		},
		circuit_connector_sprites =
		{
		  get_circuit_connector_sprites({-0.1875, -0.375}, nil, 7),
		  get_circuit_connector_sprites({0.375, -0.53125}, nil, 1),
		  get_circuit_connector_sprites({-0.1875, -0.375}, nil, 7),
		  get_circuit_connector_sprites({0.375, -0.53125}, nil, 1),
		},
		circuit_wire_max_distance = 0.1
	},
  {
    type = "explosion",
    name = "fan-sound",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = "__core__/graphics/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        line_length = 1,
        animation_speed = 1,--0.5,
      }
    },
    sound =
    {
      aggregation =
      {
        max_count = 5,
        remove = true
      },
      variations =
      {
        {
          filename = "__NauvisDay__/sound/fan-fade.ogg",
          volume = 0.5
        },
      }
    },
    created_effect = nil,
  },
})

data:extend({
  {
    type = "item",
    name = "pollution-fan",
    icon = "__NauvisDay__/graphics/icons/fan.png",
    flags = { "goes-to-quickbar" },
    subgroup = "circuit-network",
    place_result = "pollution-fan",
    order = "b[combinators]-c[pollution-fan]",
    stack_size= 50,
	--localised_name = {"entity-name.pollution-fan"},
  }
})

data:extend({
  {
    type = "recipe",
    name = "pollution-fan",
    icon = "__NauvisDay__/graphics/icons/fan.png",
    energy_required = 1.0,
    enabled = "false",
    ingredients =
    {
      {"iron-stick", 32},
      {"engine-unit", 4},
      {"pipe", 20},
    },
    result = "pollution-fan"
  }
})
