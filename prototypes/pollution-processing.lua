require "__DragonIndustries__.color"

require "constants"
require "config"

local color = convertColor(0x7C692E, true)

if Config.pollutionChem > 0 then

local f = Config.pollutionChem*pollutionProcessingConsumption
local f0 = Config.pollutionChem*Config.pollutionChemOut

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
		  {type="fluid", name="waste", amount=10*f*pollutionLiquidProductionFactor*10}, --*10 since fluids x10
		  {type="fluid", name="water", amount=20},
		},
		results = res,
		crafting_machine_tint =
		{
		  primary = color,
		  secondary = color,
		  tertiary = color,
		  quaternary = color,
		}
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
		  {type="fluid", name="waste", amount=7*f*pollutionLiquidProductionFactor*10}, --*10 since fluids x10
		  {type="fluid", name="hydrogen-chloride", amount=20}, --*10 since fluids x10
		  {type="item", name="sodium-hydroxide", amount=1},
		},
		results = {
			{type="fluid", name="oxygen", amount=10*f0},
			{type="item", name="salt", amount_min=1, amount_max=1, probability=0.6},
			{type="fluid", name="sulfur-dioxide", amount=45*f0},
		},
		crafting_machine_tint =
		{
		  primary = color,
		  secondary = color,
		  tertiary = color,
		  quaternary = color,
		}
	  },
	})
else
	local res = {{type="fluid", name="sulfuric-acid", amount=20*f0}}
	if data.raw.fluid["carbon-dioxide"] then
		table.insert(res, {type="fluid", name="carbon-dioxide", amount=5*f0})
	end
	
	data:extend({
	  {
		type = "recipe",
		name = "pollution-to-sulfuric",
		category = "chemistry",
		--order = "f[plastic-bar]-f[venting]",
		energy_required = 2,
		enabled = "false",
		ingredients = {
		  {type="fluid", name="waste", amount=1*f*pollutionLiquidProductionFactor*10}, --*10 since fluids x10
		  {type="fluid", name="water", amount=20},
		  {type="item", name="coal", amount=1}
		},
		results = res,
		crafting_machine_tint =
		{
		  primary = color,
		  secondary = color,
		  tertiary = color,
		  quaternary = color,
		}
	  },
		{
		type = "recipe",
		name = "pollution-to-sulfuric-2",
		category = "chemistry",
		--order = "f[plastic-bar]-f[venting]",
		energy_required = 2,
		enabled = "false",
		ingredients = {
		  {type="fluid", name="waste", amount=4*f*pollutionLiquidProductionFactor*10},
		  {type="fluid", name="water", amount=20},
		  {type="item", name="sulfur", amount=1}
		},
		results=
		{
		  {type="fluid", name="sulfuric-acid", amount=50*f0}
		},
		crafting_machine_tint =
		{
		  primary = color,
		  secondary = color,
		  tertiary = color,
		  quaternary = color,
		}
	  }
	})
end

end

color = convertColor(0x635C48, true)

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
      {type="fluid", name="waste", amount=math.max(1, math.ceil(120*pollutionLiquidProductionFactor*Config.pollutionChem))},
      {type="fluid", name="heavy-oil", amount=1},
      {type="item", name="stone", amount=20}
    },
    results=
    {
      {type="item", name="asphalt", amount=50}
    },
	crafting_machine_tint =
	{
	  primary = color,
	  secondary = color,
	  tertiary = color,
	  quaternary = color,
	}
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
      {type="fluid", name="waste", amount=math.max(1, math.ceil(5*pollutionLiquidProductionFactor*Config.pollutionChem))},
      {type="item", name="stone", amount=1}
    },
    results=
    {
      {type="item", name="pollution-block", amount=1}
    },
  },
})

