data:extend({
  {
    type = "assembling-machine",
    name = "dumping-machine",
    icon = "__NauvisDay__/graphics/icons/pollution-dumping-machine.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "dumping-machine"},
    fast_replaceable_group = "dumping-machine",
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
      filename = "__NauvisDay__/graphics/entity/pollution-dumping-machine-nofog.png",
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
    crafting_categories = {"pollution-dumping"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 0.5,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.125,
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
    energy_usage = "50kW",
    ingredient_count = 1,
    module_slots = 0
  }
})

data:extend({
  {
    type = "item",
    name = "dumping-machine",
    icon = "__NauvisDay__/graphics/icons/pollution-dumping-machine.png",
    flags = {  },
    subgroup = "production-machine",
    order = "f[dumping-machine]",
    place_result = "dumping-machine",
    stack_size = 10,
	icon_size = 32
  }
})

data:extend({
  {
    type = "recipe-category",
    name = "pollution-dumping"
  }
})

data:extend({
  {
    type = "recipe",
    name = "dumping-machine",
    icon = "__NauvisDay__/graphics/icons/pollution-dumping-machine.png",
	icon_size = 32,
    energy_required = 10,
    enabled = "false",
    ingredients =
    {
      {"assembling-machine-2", 1},
      {"electronic-circuit", 10},
      {"steel-plate", 10},
      {"stone-brick", 6}
    },
    result = "dumping-machine"
  },
  {
    type = "recipe",
    name = "pollution-dumping-action",
    icon = "__NauvisDay__/graphics/icons/vent-pollution.png",
	icon_size = 32,
    category = "pollution-dumping",
    order = "f[plastic-bar]-f[dumping]",
    energy_required = 0.05,
    enabled = "false",
    ingredients =
    {
      {type="fluid", name="waste", amount=2}
    },
    results=
    {
      {type="fluid", name="water", amount=0}
    },
  }
})

