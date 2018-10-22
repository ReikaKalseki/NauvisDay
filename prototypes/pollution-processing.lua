require "constants"

if data.raw.fluid["sulfur-dioxide"] then
	local res = {
		  {type="fluid", name="sulfur-dioxide", amount=30},
		  {type="item", name="carbon", amount_min=1, amount_max=1, probability=0.04}
	}
	if data.raw.fluid["nitric-oxide"] then
		table.insert(res, {type="fluid", name="nitric-oxide", amount=10})
	else
		table.insert(res, {type="fluid", name="oxygen", amount=10})
	end
	data:extend({
	  {
		type = "recipe",
		name = "pollution-to-sulfuric",
		category = "chemistry",
		--order = "f[plastic-bar]-f[venting]",
		icon = data.raw.fluid["sulfur-dioxide"].icon,
		icon_size = 32,
		energy_required = 2,
		enabled = "false",
		subgroup = "bob-fluid",
		ingredients = {
		  {type="fluid", name="waste", amount=10*pollutionProcessingConsumption*pollutionLiquidProductionFactor*10}, --*10 since fluids x10
		  {type="fluid", name="water", amount=20},
		},
		results = res,
	  },
	  {
		type = "recipe",
		name = "pollution-to-sulfuric-2",
		category = "chemistry",
		--order = "f[plastic-bar]-f[venting]",
		icon = data.raw.fluid["sulfur-dioxide"].icon,
		icon_size = 32,
		energy_required = 2,
		enabled = "false",
		subgroup = "bob-fluid",
		ingredients = {
		  {type="fluid", name="waste", amount=7*pollutionProcessingConsumption*pollutionLiquidProductionFactor*10}, --*10 since fluids x10
		  {type="fluid", name="hydrogen-chloride", amount=20}, --*10 since fluids x10
		  {type="item", name="sodium-hydroxide", amount=1},
		},
		results = {
			{type="fluid", name="oxygen", amount=10},
			{type="item", name="salt", amount_min=1, amount_max=1, probability=0.6},
			{type="fluid", name="sulfur-dioxide", amount=45},
		},
	  },
	})
else
	data:extend({
	  {
		type = "recipe",
		name = "pollution-to-sulfuric",
		category = "chemistry",
		--order = "f[plastic-bar]-f[venting]",
		energy_required = 2,
		enabled = "false",
		ingredients = {
		  {type="fluid", name="waste", amount=1*pollutionProcessingConsumption*pollutionLiquidProductionFactor*10}, --*10 since fluids x10
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
		ingredients = {
		  {type="fluid", name="waste", amount=4*pollutionProcessingConsumption*pollutionLiquidProductionFactor*10},
		  {type="fluid", name="water", amount=20},
		  {type="item", name="sulfur", amount=1}
		},
		results=
		{
		  {type="fluid", name="sulfuric-acid", amount=50}
		},
	  }
	})
end

data:extend({
   {
    type = "recipe",
    name = "asphalt",
    category = "chemistry",
    --order = "f[plastic-bar]-f[venting]",
    energy_required = 30,
    enabled = "false",
    ingredients =
    {
      {type="fluid", name="waste", amount=120*pollutionLiquidProductionFactor},
      {type="fluid", name="heavy-oil", amount=1},
      {type="item", name="stone", amount=20}
    },
    results=
    {
      {type="item", name="asphalt", amount=50}
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
  },
})

