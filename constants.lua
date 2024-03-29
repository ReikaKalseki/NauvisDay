require "config"

require "__DragonIndustries__.interpolation"

local f = math.max(1, Config.basePollutionFactor)
pollutionScale = 60*f --was 4*f before 0.18, but values needed massive rebalancing
firePollutionScale = 2*(1+(f-1)/2)
coalPollutionScale = 6*f --was 4*f before 0.18
miningPollutionScale = 5*f --was 2*f before 0.18
pollutionSpawnIncrease = 1.75/20 --/60, then /15, then /5 from 0.17's pollution redesign, then /4 again in 0.18
treePollutionAbsorptionScale = 15*f --was 10 in 0.16, the change in 0.17 broke it (tick -> second name change), and the new values did not yet take it into account

maxBoreholeSize = 500 --this is number of cycles, not fluid capacity

deaeroCoefficient = 1600 --was 900 pre 0.18, but the changes (presumably in 0.17) necessitated a buff
deaeroExponent = 1.4 -- was 1.25 until the same

noMiningCalmingFactor = 3.5 --how much more time evo (which is negative) increases if you have no mining of any kind ongoing

WALL_NUKER_MINIMUM_EVO = 0.4

local maxAttackSizeCurve = {
	{0, 10},
	{0.05, 25},--{0.05, 10},
	{0.1, 50},--{0.1, 20},
	{0.25, 100},--{0.25, 50},
	{0.5, 200},--{0.5, 100},
	{1, 400}
}
maxAttackSizeCurveLookup = buildLinearInterpolation(maxAttackSizeCurve, 0.05)

pollutionFogSizes = {
	{2500, "small"},
	{12000, "medium"},
	{45000, "big"},
	{90000, "huge"},
	{180000, ""}, --just here for a "100% huge at this value"
}

acidFogSizes = { --the keys are the ratios of pollution to minimum threshold
	{1, "small"}, --90k default
	{4/3, "medium"}, --120k at default
	{2, "big"}, --180k at default
	{8/3, "huge"}, --240k at default
	{10/3, ""}, --just here for a "100% huge at this value" - 300k at default
}

baseWormHatchTime = 60*60*15 --15 min

local wormHatchSpeedCurve = {
	{0, 1},
	{0.25, 1.5},
	{0.5, 2.5},
	{0.75, 5},
	{0.9, 10},
	{1, 25},
}
wormHatchSpeedCurveLookup = buildLinearInterpolation(wormHatchSpeedCurve, 0.05)

--These forcibly override map settings at all times to get the intended effect
pollutionAndEvo = {
	["pollution"] = {
		diffusion_ratio = 0.04,--0.25--0.1 --default is 0.02
		min_to_diffuse = 5, --default is 15
		ageing = 5,--want to increase this actually, to discourage clearing and paving--0.05--0.25 --default is 1
		min_to_show_per_chunk = 200, --default is 700
		expected_max_per_chunk = 50000, --default is 7000
		min_pollution_to_damage_trees = 36000,--20000, --default is 3500
		pollution_with_max_forest_damage = 120000,--100000, --default is 10000
		pollution_per_tree_damage = 4000, --default is 2000
		pollution_restored_per_tree_damage = 1000, --default is 500
		max_pollution_to_restore_trees = 30000,--20000, --default is 1000
		enemy_attack_pollution_consumption_modifier = 1.5 --new to 0.18 (or 0.17), default is 1
	},
	["enemy_evolution"] = {
		time_factor = {-0.000025, -0.00003},-- -0.000025,-- -0.00003,--0 --default is 0.000004
		destroy_factor = 0.0075, --default is 0.002
		pollution_factor = {0.000015/pollutionScale*pollutionSpawnIncrease, 0.0000125/pollutionScale*pollutionSpawnIncrease}, --default is 0.000015
	}
}

deaeroTickRate = 30
deaeroTickSpread = 10
overallAerosolizerWasteGenSpeed = 0.0625--0.5
local deaeroEfficiencyCurve = {
	{0, 0},
	{1000, 0.05},
	{2500, 0.2},
	{4000, 0.5},
	{10000, 0.8},
	{15000, 0.9},
	{25000, 1},
	{30000, 1.15},
	{40000, 1.5},
	{60000, 2},
	{100000, 2.5}
}
deaeroEfficiencyCurveLookup = buildLinearInterpolation(deaeroEfficiencyCurve, 500)

fanTickRate = 15
fanPollutionMoveFactor = 0.035
fanPollutionSpread =		{1,		0.975,	0.95,	0.85,	0.7,	0.5,	0.25,	0.15,	0.1,	0.05}
fanPollutionLateralSpread =	{0.9,	0.85,	0.8,	0.7,	0.6,	0.5,	0.375,	0.25,	0.1,	0.05} --Combined with the above

refineryItemConsumption = 0.5
refineryWasteProductionRatio = 1

pollutionProcessingConsumption = 0.75--1

pollutionStorageSpeedCoefficient = 5 --multiplied against the base 6/s

STEAM_FURNACES = {}

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

extraPollution = { --Further multipliers on a few entities or categories/group; stacks with the base
	["furnace"] = {
		["steel-furnace"] = 3,
		["angels-flare-stack_*"] = 100,
		["clarifier_*"] = 3,
	},
	["assembling-machine"] = {
		["assembling-machine-1"] = 4,
		["oil-refinery_*"] = 90, --was 3, then 12, then 40; needs to be a LOT
		["chemical-plant_*"] = 2,
		["ore-washer"] = 12,
		["ore-washing-plant"] = 12,
		["mixing-steel-furnace"] = 6,
		["chemical-steel-furnace"] = 6,
		["uranium-centrifuge_*"] = 4,
	},
	["boiler"] = {
		["*"] = 2, --do across category
	},
	["mining-drill"] = {
		["pumpjack_*"] = 4, --anything with "pumpjack" in the name
		["burner-mining-drill"] = 0.8, --reduce earlygame pollution a little
	},
}

recipePollutionIncreases = {
	["kovarex-enrichment-process"] = 4,
	["void-sulfur-dioxide"] = 24,
	["angels-chemical-void-sulfur-dioxide"] = 24,
	["void-chlorine"] = 40,
	["angels-chemical-void-chlorine"] = 40,
	["void-hydrogen-chloride"] = 40,
	["angels-chemical-void-hydrogen-chloride"] = 40,
	["void-carbon-monoxide"] = 30,
	["angels-chemical-void-carbon-monoxide"] = 30,
	["angels-chemical-void-formaldehyde"] = 30,
	["angels-chemical-void-urea"] = 10,
}

pollutionIncreaseExclusion = { --some machines to skip pollution modification for; either technical entities, native already-chosen ones, or ones that do not ACTUALLY do what the pollution boost is designed to "punish"
	"greenhouse", "air-filter-machine-1", "air-filter-machine-2", "air-filter-machine-3", "air-filter-machine-4", "venting-machine", "storage-machine",
	"gas-boiler", --[["steam-furnace",--]] "clean-oil-refinery", "clean-oil-refinery-2", "clean-oil-refinery-3", "clean-oil-refinery-4", --steam furnace removed because now computes based on steel-furnace
	"geothermal-well", "geothermal-heat-exchanger",
	"tf-field", "dead-bio-farm", "dead-greenhouse",
	"algae-farm", "algae-farm-2", "crop-farm", "temperate-farm", "desert-farm", "swamp-farm", "dpa"
}

for cat,entry in pairs(extraPollution) do
	for name,entry2 in pairs(entry) do
		if string.find(name, "_*", 1, true) then
			entry["HAS_WILDCARD"] = true
			--log("Adding wildcard check to category " .. cat .. " since found in " .. name)
		end
	end
end

decorativeModPollutionScales = {
	["CleanedConcrete"] = 1.03,
	["CleanFloor"] = 1.05,
	["CleanTiles"] = 1.05,
	["RealisticDecorationCleanup"] = 1.1,
	["No-Decoratives"] = 1.25,
	["Undecorate"] = 1.25,
	
	--["Naturalist"] = 0.95,
	--["Redecorate"] = 0.95,
	["TreePlant"] = 0.94,
}

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
	["burner-lab"] = 5,
	["stone-wall"] = 10,
}

pollutionLiquidProductionFactor = 1 --to make it more difficult, or even infeasible, to just store pollution in more and more tanks; not really necessary given the 10x

--Any fluid not in this list is assumed to have a factor of 1.0
liquidPollutionFactors = {

	--basically harmless
	["water"] = 0,
	["steam"] = 0,
	["pure-water"] = 0,
	["lithia-water"] = 0.05,
	["oxygen"] = 0,
	["nitrogen"] = 0,
	["air"] = 0,
	["liquid-air"] = 0,
	["compressed-air"] = 0,
	["hydrogen"] = 0.01,
	
	--mildly toxic/unpleasant, low pollution
	["carbon-dioxide"] = 0.4,
	["nitrogen-dioxide"] = 0.8,
	["nitrogen-oxide"] = 0.6,
	["ozone"] = 0.5,
	["hydrogen-peroxide"] = 0.7, --oxidizer but decomposes to O2 and water, leaving no widespread effects
	["ethanol"] = 0.3,
	["acetone"] = 0.2,
	["isopropanol"] = 0.25,
	["acetic-acid"] = 0.1,
		
	--moderately toxic/unpleasant, moderate pollution
	["crude-oil"] = 1.4,
	["heavy-oil"] = 1.5,
	["light-oil"] = 1.2,
	["petroleum-gas"] = 0.9, --methane = greenhouse effect, but is not really toxic nor something noticeable
	["ammonia"] = 1.1,
	["benzene"] = 1.5,
	
	--highly toxic, highly polluting
	["carbon-monoxide"] = 1.6,
	["chlorine"] = 2.5,
	["dinitrogen-tetroxide"] = 1.8,
	["hydrogen-sulfide"] = 2.0,
	["sulfur-dioxide"] = 2.3,
	
	--spill this and weep
	["hydrogen-cyanide"] = 5.7,
	["hydrazine"] = 4.5,
	["hydrogen-chloride"] = 4.0,
	["nitric-acid"] = 6,
	["sulfuric-acid"] = 3.6,
	["formaldehyde"] = 4,
	
	["waste"] = 80 --somewhat offset by very low evaporation rate
}

--Any fluid not in this list is assumed to have a factor of 1.0; this also affects pollution dissipation rate (and possibly max value reached if it cannot spread in time to other chunks), but not total
liquidEvaporationFactors = {
	["water"] = 1.1,
	["pure-water"] = 1.1,
	
	["steam"] = 16,--8,
	["nitrogen"] = 5,
	["oxygen"] = 5,
	["ozone"] = 4,
	["hydrogen"] = 10,
	["petroleum-gas"] = 2,
	["chlorine"] = 1.5,
	["air"] = 15,
	["liquid-air"] = 15,
	["compressed-air"] = 15,
	
	["sulfur-dioxide"] = 2,
	["nitrogen-dioxide"] = 2,
	["nitrogen-oxide"] = 2,
	["carbon-dioxide"] = 2,
	["carbon-monoxide"] = 2,
	
	["nitric-acid"] = 0.5,
	["sulfuric-acid"] = 0.5,
	["hydrogen-chloride"] = 1.8,
	
	["ethanol"] = 2.5,
	["acetone"] = 1.8,
	["benzene"] = 1.5,
	
	["hydrogen-peroxide"] = 6, --to simulate rapid decomposition, and to make more immediately dangerous
	
	["crude-oil"] = 0.2,
	["heavy-oil"] = 0.15,
	["light-oil"] = 0.35,
	["lubricant"] = 0.25,
	
	["waste"] = 0.04
}

--Anything not in the list is considered harmless for stepping in. This is 4-times-per-second damage
liquidDamageLevels = {
	["steam"] = 0.125,
	["ozone"] = 0.5,
	["hydrogen-peroxide"] = 2,
	["chlorine"] = 4,
	["sulfur-dioxide"] = 2,
	["carbon-monoxide"] = 2,
	["sulfuric-acid"] = 3,
	["formaldehyde"] = 3.5,
	["hydrazine"] = 4,
	["hydrogen-chloride"] = 5,
	["nitric-acid"] = 6,
	["hydrogen-cyanide"] = 10,
	["benzene"] = 1,
	
	["waste"] = 1
}