if data.raw.item["carbon"] then
	--do nothing, takes item directly
elseif data.raw.item["charcoal"] then
	
else
	data:extend({
		{
			type = "item",
			name = "charcoal",
			icon = "__NauvisDay__/graphics/icons/charcoal.png",
			icon_size = 32,
			flags = { "goes-to-quickbar" },
			subgroup = "intermediate-product",
			order = "f[charcoal]",
			stack_size = 200,
			icon_size = 32
		},
	  {
		type = "recipe",
		name = "charcoal-1",
		icon = "__NauvisDay__/graphics/icons/charcoal.png",
		icon_size = 32,
		energy_required = 0.5,
		category = "smelting",
		enabled = "true",
		ingredients =
		{
		  {"coal", 1},
		},
		result = "charcoal"
	  }, 
	  {
		type = "recipe",
		name = "charcoal-2",
		icon = "__NauvisDay__/graphics/icons/charcoal.png",
		icon_size = 32,
		energy_required = 0.5,
		category = "smelting",
		enabled = "true",
		ingredients =
		{
		  {"raw-wood", 2},
		},
		result = "charcoal",
		result_count = 3
	  }, 
	})
end

if data.raw.item["carbon"] == nil then
	data:extend({
		{
			type = "item",
			name = "air-filter",
			icon = "__NauvisDay__/graphics/icons/air-filter.png",
			icon_size = 32,
			flags = { "goes-to-quickbar" },
			subgroup = "intermediate-product",
			order = "f[air-filter]",
			stack_size = 25,
			icon_size = 32
		},
		{
			type = "item",
			name = "air-filter-case",
			icon = "__NauvisDay__/graphics/icons/air-filter-case.png",
			icon_size = 32,
			flags = { "goes-to-quickbar" },
			subgroup = "intermediate-product",
			order = "f[air-filter-case]",
			stack_size = 25,
			icon_size = 32
		},
	  {
		type = "recipe",
		name = "air-filter-case",
		icon = "__NauvisDay__/graphics/icons/air-filter-case.png",
		icon_size = 32,
		energy_required = 1,
		enabled = "false",
		ingredients =
		{
		  {"iron-stick", 10},
		  {"copper-plate", 1},
		},
		result = "air-filter-case"
	  }, 
	  {
		type = "recipe",
		name = "air-filter-filling",
		icon = "__NauvisDay__/graphics/icons/air-filter.png",
		icon_size = 32,
		energy_required = 1,
		enabled = "false",
		ingredients = {
			{"air-filter-case", 1},
			{"charcoal", 4}
		},
		result = "air-filter"
	  }, 
	})
	
	table.insert(data.raw.technology["pollution-capture"].effects, {type = "unlock-recipe", recipe = "air-filter-case"})
	table.insert(data.raw.technology["pollution-capture"].effects, {type = "unlock-recipe", recipe = "air-filter-filling"})
end