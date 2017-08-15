require "config"

local f = math.max(1, Config.basePollutionFactor)
pollutionScale = 4*f
firePollutionScale = 2*(1+(f-1)/2)
coalPollutionScale = 4*f
miningPollutionScale = 2*f
pollutionSpawnIncrease = 1.75

overallAerosolizerWasteGenSpeed = 0.0625--0.5

maxBoreholeSize = 1000000 --since fluids are x10, max size is this, but only has 1/10th as many "cycles"

maxAttackSizeCurve = {
	{0, 5},
	{0.05, 20},--{0.05, 10},
	{0.1, 40},--{0.1, 20},
	{0.25, 100},--{0.25, 50},
	{0.5, 200},--{0.5, 100},
	{1, 200}
}

--These forcibly override map settings at all times to get the intended effect
pollutionAndEvo = {
	["pollution"] = {
		diffusion_ratio = 0.05,--0.25--0.1 --default is 0.02
		min_to_diffuse = 5, --default is 15
		ageing = 2,--want to increase this actually, to discourage paving--0.05--0.25 --default is 1
		min_to_show_per_chunk = 200, --default is 700
		expected_max_per_chunk = 40000, --default is 7000
		min_pollution_to_damage_trees = 36000,--20000, --default is 3500
		pollution_with_max_forest_damage = 120000,--100000, --default is 10000
		pollution_per_tree_damage = 4000, --default is 2000
		pollution_restored_per_tree_damage = 1000, --default is 500
		max_pollution_to_restore_trees = 30000,--20000, --default is 1000
	},
	["enemy_evolution"] = {
		time_factor = -0.000025,-- -0.00003,--0 --default is 0.000004
		destroy_factor = 0.0075, --default is 0.002
		pollution_factor = 0.000015/pollutionScale*pollutionSpawnIncrease, --default is 0.000015
	}
}

fanTickRate = 15
fanPollutionMoveFactor = 0.025
fanPollutionSpread =		{1,		0.975,	0.95,	0.85,	0.7,	0.5,	0.25,	0.15,	0.1,	0.05}
fanPollutionLateralSpread =	{0.9,	0.85,	0.8,	0.7,	0.6,	0.5,	0.375,	0.25,	0.1,	0.05} --Combined with the above

waterConversionPatterns = { --weighted random
	{50, {{1}}},
	{25, {{1, 1}, {1, 1}}},
	{25, {{0, 1, 0}, {1, 1, 1}, {0, 1, 0}}},
	{20, {{0, 1, 1}, {1, 1, 1}, {1, 1, 0}}},
	{20, {{1, 1, 0}, {1, 1, 1}, {1, 1, 0}}},
	{15, {{0, 1, 0}, {1, 1, 1}, {1, 1, 1}, {0, 1, 0}}},
	{15, {{0, 1, 1, 1, 0}, {1, 1, 1, 1, 1}, {0, 1, 1, 1, 0}}},
	{5, {{0, 0, 1, 0, 0}, {0, 1, 1, 1, 0}, {1, 1, 1, 1, 1}, {0, 1, 1, 1, 0}, {0, 0, 1, 0, 0}}},
}

extraPollution = { --Further multipliers on a few entities or categories/group
	["furnace"] = {
		["steel-furnace"] = 2, --stacks with the previous 16x
	},
	["assembling-machine"] = {
		["assembling-machine-1"] = 4,
		["oil-refinery"] = 60, --was 3, then 12, then 40; needs to be a LOT
		["chemical-plant"] = 2,
		["ore-washer"] = 12,
		["ore-washing-plant"] = 12,
	},
	["boiler"] = {
		["*"] = 1.2, --do across category
	},
	["mining-drill"] = {
		["pumpjack_*"] = 4, --anything with "pumpjack" in the name
	},
}

pollutionIncreaseExclusion = { --some machines to skip pollution modification for; either technical entities, native already-chosen ones, or ones that do not ACTUALLY do what the pollution boost is designed to "punish"
	"greenhouse", "air-filter-machine-1", "air-filter-machine-2", "air-filter-machine-3", "air-filter-machine-4", "venting-machine", "storage-machine", "gas-boiler", "gas-boiler-input", "steam-furnace", "geothermal-well", "geothermal-heat-exchanger", "tf-field"
}

for cat,entry in pairs(extraPollution) do
	for name,entry2 in pairs(entry) do
		if string.find(name, "_*", 1, true) then
			entry["HAS_WILDCARD"] = true
			--log("Adding wildcard check to category " .. cat .. " since found in " .. name)
		end
	end
end

 --entity types, that if placed in sufficient number, give a 'green light' to biter attacks, signifying sufficient progression to make them reasonably survivable. As long as ANY have been met the attacks are permitted.
attackGreenlightingTypes = {
	["boiler"] = 2,
	["burner-generator"] = 1,
	["steam-engine"] = 2,
	["burner-mining-drill"] = 4,
	["stone-furnace"] = 8,
	["electric-mining-drill"] = 3,
	["transport-belt"] = 100,
	["gun-turret"] = 1,
	["lab"] = 2,
	["stone-wall"] = 5,
}

pollutionLiquidProductionFactor = 1 --to make it more difficult, or even infeasible, to just store pollution in more and more tanks; not really necessary given the 10x