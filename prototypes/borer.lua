require "constants"

data:extend({
  {
    type = "assembling-machine",
    name = "borer",
    icon = "__NauvisDay__/graphics/icons/borer.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "borer"},
    fast_replaceable_group = "borer",
    max_health = 400,
    corpse = "big-remnants",
    collision_box = {{-2.3, -2.7}, {2.3, 1.9}},
    selection_box = {{-2.5, -2.9}, {2.5, 2.1}},
    animation =
    {
       priority = "extra-high",
       width = 159,
       height = 115,
       line_length = 4,
       shift = {0.6, -0.4},
       filename = "__NauvisDay__/graphics/entity/borer-anim.png",
       frame_count = 32,
	   scale = 1.25,
       animation_speed = 1.0,
       --run_mode = "forward-then-backward",
	   --[[
       hr_version = {
         priority = "extra-high",
         width = 173,
         height = 188,
         line_length = 4,
         shift = {0, -1},
         filename = "__NauvisDay__/graphics/entity/hr-borer.png",
         frame_count = 32,
         animation_speed = 1.0,
         --run_mode = "forward-then-backward",
         scale = 1.0
        }
		--]]
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__NauvisDay__/sound/borer.ogg", volume = 0.9 } },
      idle_sound = { filename = "__NauvisDay__/sound/borer-idle.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"boring"},
    source_inventory_size = 5,
    result_inventory_size = 1,
    crafting_speed = 1,
    fluid_boxes =
    {
      {
        production_type = "output",
        pipe_picture = nil,
        pipe_covers = nil,
        base_area = 1,
        base_level = 1,
        pipe_connections = {},
        secondary_draw_orders = { north = -1 }
      },
      off_when_no_fluid_recipe = true
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.06,
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
	fixed_recipe = "boring-action",
    energy_usage = "2.75MW",
    ingredient_count = 5,
    module_slots = 0,
    allowed_effects = nil, --no modules
  }
})

data:extend({
  {
    type = "item",
    name = "borer",
    icon = "__NauvisDay__/graphics/icons/borer.png",
	icon_size = 32,
    flags = { "goes-to-quickbar" },
    subgroup = "production-machine",
    order = "f[borer]",
    place_result = "borer",
    stack_size = 10,
	icon_size = 32
  }
})

data:extend({
  {
    type = "recipe-category",
    name = "boring"
  }
})

data:extend({
  {
    type = "recipe",
    name = "borer",
    icon = "__NauvisDay__/graphics/icons/borer.png",
	icon_size = 32,
    energy_required = 10,
    enabled = "false",
    ingredients =
    {
      {"electric-mining-drill", 4},
      {"electronic-circuit", 10},
	  {"steel-plate", 100},
      {"stone-brick", 50}
    },
    result = "borer"
  },
  {
    type = "recipe",
    name = "boring-action",
    icon = "__NauvisDay__/graphics/icons/boring-action.png",
	icon_size = 32,
    category = "boring",
    order = "f[plastic-bar]-f[boring]",
    energy_required = 15,
	localised_name = "recipe-name.boring-action",
	hidden = true,
    enabled = "false",
    ingredients =
    {
      {type="item", name="concrete", amount=200},
      {type="item", name="construction-robot", amount=1},
      {type="item", name="steel-axe", amount=2},
      {type="item", name="plastic-bar", amount=5},
    },
    results=
    {
      {type="fluid", name="water", amount=0}
    },
  }
})

