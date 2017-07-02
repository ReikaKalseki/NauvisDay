require "constants"

data:extend({
  {
    type = "recipe",
    name = "pollution-to-sulfuric",
    category = "chemistry",
    --order = "f[plastic-bar]-f[venting]",
    energy_required = 2,
    enabled = "false",
    ingredients =
    {
      {type="fluid", name="waste", amount=1*pollutionLiquidProductionFactor*10}, --*10 since fluids x10
      {type="fluid", name="water", amount=20},
      {type="item", name="coal", amount=1}
    },
    results=
    {
      {type="fluid", name="sulfuric-acid", amount=20}
    },
  },
    {
    type = "recipe",
    name = "pollution-to-sulfuric-2",
    category = "chemistry",
    --order = "f[plastic-bar]-f[venting]",
    energy_required = 2,
    enabled = "false",
    ingredients =
    {
      {type="fluid", name="waste", amount=4*pollutionLiquidProductionFactor*10},
      {type="fluid", name="water", amount=20},
      {type="item", name="sulfur", amount=1}
    },
    results=
    {
      {type="fluid", name="sulfuric-acid", amount=50}
    },
  }
})

data:extend({
  {
    type = "recipe",
    name = "pollution-binding",
    category = "advanced-crafting",
    --order = "f[plastic-bar]-f[venting]",
    energy_required = 1,
    enabled = "false",
    ingredients =
    {
      {type="fluid", name="waste", amount=5*pollutionLiquidProductionFactor},
      {type="item", name="stone", amount=1}
    },
    results=
    {
      {type="item", name="pollution-block", amount=1}
    },
  }
})

