require "config"

if Config.enableRefinery then
	local eff = {}
	for name,entity in pairs(data.raw["assembling-machine"]) do
		if #entity.crafting_categories == 1 and entity.crafting_categories[1] == "clean-oil-processing" then
			local r1 = name .. "-upgrade"
			local r2 = name .. "-conversion"
			if data.raw.recipe[r1] then table.insert(eff, {type = "unlock-recipe", recipe = r1}) end
			if data.raw.recipe[r2] then table.insert(eff, {type = "unlock-recipe", recipe = r2}) end
		end
	end

	data:extend({
		{
		type = "technology",
		name = "clean-oil-processing",
		prerequisites =
		{
			"advanced-oil-processing",
			"advanced-pollution-capture",
		},
		icon = "__NauvisDay__/graphics/technology/clean-oil.png",
		effects = eff,
		unit =
		{
		  count = 90,
		  ingredients =
		  {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1}
		  },
		  time = 40
		},
		order = "[steam]-2",
		icon_size = 128,
	  }
	})
end


if Config.enableRefinery and data.raw.technology["chemical-processing-2"] then
	table.insert(data.raw.technology["clean-oil-processing"].prerequisites, "chemical-processing-2")
end