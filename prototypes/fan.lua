data:extend({
	{
		type = "resource-category",
		name = "pollution-fan"
	},
  {
    type = "mining-drill",
    name = "pollution-fan",
    icon = "__NauvisDay__/graphics/icons/fan.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "pollution-fan"},
    max_health = 100,
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
    resource_searching_radius = 0.5,
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
  }
})

data:extend({
  {
    type = "item",
    name = "pollution-fan",
    icon = "__NauvisDay__/graphics/icons/fan.png",
    flags = { "goes-to-quickbar" },
    subgroup = "circuit-network",
    place_result="pollution-fan",
    order = "b[combinators]-c[pollution-fan]",
    stack_size= 50,
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
      {"electric-engine-unit", 4},
      {"pipe", 20},
    },
    result = "pollution-fan"
  }
})
