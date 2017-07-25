require "constants"

local function createFilter(tier, speedFactor, efficiency) --efficiency can be > 1
	local ret =
	{
    type = "assembling-machine",
    name = "air-filter-machine-" .. tier,
    icon = "__NauvisDay__/graphics/icons/air-filter-machine.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2+0.05*tier, mining_time = 0.5, result = "air-filter-machine-" .. tier},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150*tier,
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
      off_when_no_fluid_recipe = false
    },
    animation =
    {
      filename = "__NauvisDay__/graphics/entity/air-filter-machine.png",
      priority = "high",
      width = 99,
      height = 102,
      frame_count = 32,
      line_length = 8,
      shift = {0.4, -0.06},
	  animation_speed = 1/speedFactor,
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__NauvisDay__/sound/filter.ogg", volume = 1.0 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"air-cleaning"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 1*speedFactor/efficiency,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = -0.25*(1+(speedFactor-1)/2)*3
    },
    energy_usage = (600*speedFactor) .. "kW",
    ingredient_count = 1,
    module_slots = 0,
    allowed_effects = nil, --no modules
  }
  return ret
end

data:extend({
	createFilter(1, 0.25, 0.75),
	createFilter(2, 0.5, 1),
	createFilter(3, 1, 1.5),
	createFilter(4, 2, 2.5),
})

for tier = 1,4 do
	data:extend({
	  {
		type = "item",
		name = "air-filter-machine-" .. tier,
		icon = "__NauvisDay__/graphics/icons/air-filter-machine-" .. tier .. ".png",
		flags = { "goes-to-quickbar" },
		subgroup = "production-machine",
		order = "f[air-filter-machine]",
		place_result = "air-filter-machine-" .. tier,
		stack_size = 10
	  }
	})
end

data:extend({
  {
    type = "recipe-category",
    name = "air-cleaning"
  }
})

data:extend({
  {
    type = "recipe",
    name = "air-cleaning-action",
    icon = "__NauvisDay__/graphics/icons/filter-air.png",
    category = "air-cleaning",
    order = "f[plastic-bar]-f[cleaning]",
    energy_required = 0.2/overallAerosolizerWasteGenSpeed,
    enabled = "false",
    ingredients =
    {
      {type="fluid", name="water", amount=10*5*(1+(pollutionLiquidProductionFactor-1)/2)}
    },
    results=
    {
      {type="fluid", name="waste", amount=10*5*pollutionLiquidProductionFactor}
    },
  },
  
  {
    type = "recipe",
    name = "air-filter-machine-1",
    icon = "__NauvisDay__/graphics/icons/air-filter-machine-1.png",
    energy_required = 6,
    enabled = "false",
    ingredients =
    {
      {"assembling-machine-1", 1},
      {"electronic-circuit", 6},
      {"stone-brick", 5}
    },
    result = "air-filter-machine-1"
  },  
  {
    type = "recipe",
    name = "air-filter-machine-2",
    icon = "__NauvisDay__/graphics/icons/air-filter-machine-2.png",
    energy_required = 10,
    enabled = "false",
    ingredients =
    {
      {"assembling-machine-2", 1},
      {"electronic-circuit", 10},
      {"steel-plate", 10},
      {"stone-brick", 6}
    },
    result = "air-filter-machine-2"
  },
  {
    type = "recipe",
    name = "air-filter-machine-2b",
    icon = "__NauvisDay__/graphics/icons/air-filter-machine-2.png",
    energy_required = 10,
    enabled = "false",
    ingredients =
    {
      {"air-filter-machine-1", 1},
      {"electronic-circuit", 4},
      {"steel-plate", 10},
      {"stone-brick", 1},
      {"iron-gear-wheel", 4}
    },
    result = "air-filter-machine-2"
  }, 
  {
    type = "recipe",
    name = "air-filter-machine-3",
    icon = "__NauvisDay__/graphics/icons/air-filter-machine-3.png",
    energy_required = 10,
    enabled = "false",
    ingredients =
    {
      {"assembling-machine-2", 1},
      {"advanced-circuit", 5},
      {"steel-plate", 10},
      {"concrete", 20}
    },
    result = "air-filter-machine-3"
  },
  {
    type = "recipe",
    name = "air-filter-machine-3b",
    icon = "__NauvisDay__/graphics/icons/air-filter-machine-3.png",
    energy_required = 10,
    enabled = "false",
    ingredients =
    {
      {"air-filter-machine-2", 1},
      {"advanced-circuit", 5},
      {"steel-plate", 5},
      {"concrete", 20}
    },
    result = "air-filter-machine-3"
  }, 
  {
    type = "recipe",
    name = "air-filter-machine-4",
    icon = "__NauvisDay__/graphics/icons/air-filter-machine-4.png",
    energy_required = 10,
    enabled = "false",
    ingredients =
    {
      {"assembling-machine-3", 1},
      {"processing-unit", 5},
      {"steel-plate", 20},
      {"concrete", 20}
    },
    result = "air-filter-machine-4"
  },
  {
    type = "recipe",
    name = "air-filter-machine-4b",
    icon = "__NauvisDay__/graphics/icons/air-filter-machine-4.png",
    energy_required = 10,
    enabled = "false",
    ingredients =
    {
      {"air-filter-machine-3", 1},
      {"processing-unit", 5},
      {"steel-plate", 5},
      {"concrete", 5},
      {"speed-module", 3},
      {"iron-gear-wheel", 10},
    },
    result = "air-filter-machine-4"
  }
})

