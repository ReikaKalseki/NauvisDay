require "constants"

data:extend({
  {
    type = "assembling-machine",
    name = "venting-machine",
    icon = "__NauvisDay__/graphics/icons/pollution-venting-machine.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "venting-machine"},
    fast_replaceable_group = "venting-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, -2} }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = 1,
        pipe_connections = {{ type="output", position = {0, 2} }},
        secondary_draw_orders = { north = -1 }
      },
      off_when_no_fluid_recipe = true
    },
    animation =
    {
      filename = "__NauvisDay__/graphics/entity/pollution-venting-machine-nofog.png",
      priority = "high",
      width = 99,
      height = 102,
      frame_count = 32,
      line_length = 8,
      shift = {0.4, -0.06}
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__NauvisDay__/sound/venter.ogg", volume = 0.4 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"pollution-venting"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 0.5*overallAerosolizerWasteGenSpeed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 80, --from 8
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
	fixed_recipe = "pollution-venting-action",
    energy_usage = "50kW",
    ingredient_count = 1,
    module_slots = 0,
    allowed_effects = nil, --no modules
  }
})

data:extend({
  {
    type = "item",
    name = "venting-machine",
    icon = "__NauvisDay__/graphics/icons/pollution-venting-machine.png",
    flags = {  },
    subgroup = "production-machine",
    order = "f[venting-machine]",
    place_result = "venting-machine",
    stack_size = 10,
	icon_size = 32
  }
})

data:extend({
  {
    type = "recipe-category",
    name = "pollution-venting"
  }
})

data:extend({
  {
    type = "recipe",
    name = "venting-machine",
    icon = "__NauvisDay__/graphics/icons/pollution-venting-machine.png",
	icon_size = 32,
    energy_required = 10,
    enabled = "false",
    ingredients =
    {
      {"assembling-machine-1", 1},
      {"electronic-circuit", 8},
      {"stone-brick", 4}
    },
    result = "venting-machine"
  },
  {
    type = "recipe",
    name = "pollution-venting-action",
    icon = "__NauvisDay__/graphics/icons/vent-pollution.png",
	icon_size = 32,
    category = "pollution-venting",
    order = "f[plastic-bar]-f[venting]",
    energy_required = 0.05,
    enabled = "false",
	hidden = true,
    ingredients =
    {
      {type="fluid", name="waste", amount=2*pollutionLiquidProductionFactor*10}
    },
    results=
    {
      {type="fluid", name="water", amount=0}
    },
  }
})

