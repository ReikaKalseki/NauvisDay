require "constants"

local function createFilter()
	local ret =
	{
    type = "assembling-machine",
    name = "greenhouse",
    icon = "__NauvisDay__/graphics/icons/greenhouse.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "greenhouse"},
    fast_replaceable_group = "greenhouse",
    max_health = 100,
    corpse = "big-remnants",
    collision_box = {{-3.8, -3.8}, {3.8, 3.8}},
    selection_box = {{-4, -4}, {4, 4}},
    fluid_boxes =
    {
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(), --looks bad
        pipe_covers = pipecoverspictures(),
        base_area = 1000,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-3.5, -4.5} }},
        secondary_draw_orders = { north = -1 }
      },
      off_when_no_fluid_recipe = false
    },
    animation =
    {
      filename = "__NauvisDay__/graphics/entity/greenhouse.png",
      priority = "high",
      width = 296,
      height = 260,
      shift = {0.5, 0},
      frame_count = 1,
      line_length = 1,
	  animation_speed = 1,
    },
    --open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    --close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__NauvisDay__/sound/greenhouse.ogg", volume = 0.8 } },
      --idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"greenhouse"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = -0.5,-- -0.05, --this is per power input, and since power is very low, needs to be large to have any real effect; compare with min-tier deaero which is 150kW with val of 0.46875 -> would need 5x bigger for same effect here
    },
    energy_usage = "30kW",
    ingredient_count = 1,
    module_slots = 0,
    allowed_effects = nil, --no modules
  }
  return ret
end

data:extend({
	createFilter(),
})

data:extend({
  {
	type = "item",
	name = "greenhouse",
	icon = "__NauvisDay__/graphics/icons/greenhouse.png",
	flags = { "goes-to-quickbar" },
	subgroup = "production-machine",
	order = "f[greenhouse]",
	place_result = "greenhouse",
	stack_size = 10,
	icon_size = 32
  }
})

data:extend({
  {
    type = "recipe-category",
    name = "greenhouse"
  }
})

data:extend({
  {
    type = "recipe",
    name = "greenhouse-action",
    icon = "__NauvisDay__/graphics/icons/greenhouse-recipe.png",
	icon_size = 32,
    category = "greenhouse",
    order = "f[plastic-bar]-f[cleaning]",
    energy_required = 300,
    enabled = "true",
    ingredients =
    {
      {type="fluid", name="water", amount=3000}
    },
    results=
    {
      {type="item", name="raw-wood", amount=5*10}
    },
  },
  
  {
    type = "recipe",
    name = "greenhouse",
    icon = "__NauvisDay__/graphics/icons/greenhouse.png",
	icon_size = 32,
    energy_required = 6,
    enabled = "true",
    ingredients =
    {
      {"iron-stick", 40},
      {"small-lamp", 4},
      {"copper-cable", 12},
      {"stone", 20},
    },
    result = "greenhouse"
  },
})

