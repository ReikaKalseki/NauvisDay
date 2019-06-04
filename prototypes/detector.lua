require("__DragonIndustries__.cloning")

local detector = createSignalOutput("NauvisDay", "pollution-detector")

data:extend({
  detector
})


data:extend({
  {
    type = "item",
    name = "pollution-detector",
    icon = "__NauvisDay__/graphics/icons/pollution-detector.png",
	icon_size = 32,
    flags = {  },
    subgroup = "circuit-network",
    place_result="pollution-detector",
    order = "b[combinators]-c[pollution-detector]",
    stack_size = 50,
	icon_size = 32
  },
  { --for display in the circuit gui
    type = "virtual-signal",
    name = "pollution",
    icon = "__NauvisDay__/graphics/icons/pollution.png",
	icon_size = 32,
    subgroup = "virtual-signal-special",
    order = "pollution",
  }
})



data:extend({
  {
    type = "recipe",
    name = "pollution-detector",
    icon = "__NauvisDay__/graphics/icons/pollution-detector.png",
	icon_size = 32,
    energy_required = 1.0,
    enabled = "false",
    ingredients =
    {
      {"constant-combinator", 1},
      {"electronic-circuit", 5},
      {"coal", 2},
    },
    result = "pollution-detector"
  }
})
