require "config"

data:extend(
{
  {
    type = "technology",
    name = "pollution-capture",
    prerequisites =
    {
		"fluid-handling",
		"engine",
    },
    icon = "__NauvisDay__/graphics/technology/pollution.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-1"
      },
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-2"
      },
      {
        type = "unlock-recipe",
        recipe = "air-cleaning-action"
      },
      {
        type = "unlock-recipe",
        recipe = "venting-machine"
      },
      {
        type = "unlock-recipe",
        recipe = "pollution-venting-action"
      },
      {
        type = "unlock-recipe",
        recipe = "pollution-fan"
      },
    },
    unit =
    {
      count = 60,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 20
    },
    order = "[steam]-2",
	icon_size = 128,
  },
    {
    type = "technology",
    name = "advanced-pollution-capture",
    prerequisites =
    {
		"pollution-capture",
		"advanced-electronics",
		"concrete",
    },
    icon = "__NauvisDay__/graphics/technology/pollution.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-3"
      },
    },
    unit =
    {
      count = 80,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 20
    },
    order = "[steam]-2",
	icon_size = 128,
  },
    {
    type = "technology",
    name = "advanced-pollution-capture-2",
    prerequisites =
    {
		"advanced-pollution-capture",
		"advanced-oil-processing",
		"automation-3",
		"electric-engine",
		"advanced-electronics-2",
    },
    icon = "__NauvisDay__/graphics/technology/pollution.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-4"
      },
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 20
    },
    order = "[steam]-2",
	icon_size = 128,
  },
    {
    type = "technology",
    name = "pollution-processing",
    prerequisites =
    {
		"pollution-capture",
		"sulfur-processing"
    },
    icon = "__NauvisDay__/graphics/technology/pollution-processing.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "pollution-to-sulfuric"
      },
      {
        type = "unlock-recipe",
        recipe = "pollution-to-sulfuric-2"
      },
      {
        type = "unlock-recipe",
        recipe = "asphalt"
      },
      {
        type = "unlock-recipe",
        recipe = "pollution-binding"
      },
    },
    unit =
    {
      count = 60,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "[steam]-2",
	icon_size = 128,
  },
    {
    type = "technology",
    name = "pollution-storage",
    prerequisites =
    {
		"pollution-capture",
    },
    icon = "__NauvisDay__/graphics/technology/pollution.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "storage-machine"
      },
    },
    unit =
    {
      count = 60,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 45
    },
    order = "[steam]-2",
	icon_size = 128,
  },
    {
    type = "technology",
    name = "pollution-storage-2",
    prerequisites =
    {
		"pollution-storage",
		"production-science-pack"
    },
    icon = "__NauvisDay__/graphics/technology/pollution.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "borer"
      },
      {
        type = "unlock-recipe",
        recipe = "boring-action"
      },
      {
        type = "nothing",
		effect_description = {"modifier-description.storage-effects"}
      },
    },
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 60
    },
    order = "[steam]-2",
	icon_size = 128,
  },
}
)