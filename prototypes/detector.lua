require("__DragonIndustries__.cloning")
require("__DragonIndustries__.registration")

local detector = createSignalOutput("NauvisDay", "pollution-detector", "pollution")

detector.entity.icon_size = 32
detector.entity.icon_mipmaps = 0
detector.item.icon_size = 32
detector.item.icon_mipmaps = 0
detector.signal.icon_size = 32
detector.signal.icon_mipmaps = 0

registerObjectArray(detector)

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
