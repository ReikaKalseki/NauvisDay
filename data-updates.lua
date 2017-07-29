require "config"
require "constants"

--[[
data.raw["map-settings"]["map-settings"].pollution.diffusion_ratio = 0.05--0.25--0.1 --default is 0.02
data.raw["map-settings"]["map-settings"].pollution.min_to_diffuse = 5 --default is 15
data.raw["map-settings"]["map-settings"].pollution.ageing = 2--want to increase this actually, to discourage paving--0.05--0.25 --default is 1
data.raw["map-settings"]["map-settings"].min_to_show_per_chunk = 200 --default is 700

data.raw["map-settings"]["map-settings"].enemy_evolution.time_factor = -0.00003--0 --default is 0.000004
data.raw["map-settings"]["map-settings"].enemy_evolution.destroy_factor = 0.005 --default is 0.002
data.raw["map-settings"]["map-settings"].enemy_evolution.pollution_factor = data.raw["map-settings"]["map-settings"].enemy_evolution.pollution_factor/pollutionScale*pollutionSpawnIncrease/1.25 --/1.5 to account for dramatic pollution increase
--]]
for category, params in pairs(pollutionAndEvo) do
	for entry, val in pairs(params) do
		data.raw["map-settings"]["map-settings"][category][entry] = val
	end
end

local coalBurners = {"boiler", "furnace", "mining-drill"}--, "inserter", "car", "locomotive"} these do not have emissions params; do they even pollute? (reddit says no)
for idx,label in pairs(coalBurners) do
	for k,obj in pairs(data.raw[label]) do
		--log(serpent.block("Checking candidate coal burner '" .. k .. "'"))
		if obj.energy_source.type == "burner" and obj.energy_source.fuel_category == "chemical" and (obj.name ~= "gas-boiler" and obj.name ~= "steam-furnace") then
			--log(serpent.block("ID'ed coal burner '" .. k .. "', increasing emissions " .. coalPollutionScale .. "x"))
			if obj.energy_source.emissions then
				obj.energy_source.emissions = obj.energy_source.emissions*coalPollutionScale
				--log(serpent.block("Success"))
			else
				--log(serpent.block("Entity had no emissions parameter. Entity: "))
				--log(serpent.block(obj))
			end
		end
	end
end

for name,tree in pairs(data.raw["tree"]) do
	if not string.find(name, "dead") then
		--log(serpent.block("Checking candidate coal burner '" .. k .. "'"))
		--log(serpent.block("ID'ed coal burner '" .. k .. "', increasing emissions " .. pollutionScale*coalPollutionScale .. "x"))
		tree.emissions_per_tick = tree.emissions_per_tick*10
	end
end

data.raw.recipe["firearm-magazine"].ingredients = {{"iron-plate", 3}} -- go from 4 plates to 1.5 plates each
data.raw.recipe["firearm-magazine"].result_count = 2 --since attacks are going to be VERY frequent and early game resources are at a premium; since this ammo is obsoleted rapidly, does not affect mid to late game

data.raw.unit["small-biter"].pollution_to_join_attack = 500 --was 200, then 400
--[[
data.raw.unit["small-biter"].max_health = 10 --was 15
data.raw.unit["small-biter"].attack_parameters.ammo_type = make_unit_melee_ammo_type(5) --was 7
--]]

local polluters = {"assembling-machine", "pump", "mining-drill", "furnace"} --assembly also includes chem plant, refinery, centrifuge
for idx,label in pairs(polluters) do
	for k,obj in pairs(data.raw[label]) do
		--log(serpent.block("Checking candidate polluter '" .. k .. "'"))
		--log(serpent.block("ID'ed polluter '" .. k .. "', increasing emissions " .. pollutionScale .. "x"))
		if obj.energy_source.emissions then
			obj.energy_source.emissions = obj.energy_source.emissions*pollutionScale
			if label == "mining-drill" then
				obj.energy_source.emissions = obj.energy_source.emissions*miningPollutionScale
				--log(serpent.block("ID'ed mining polluter '" .. k .. "', increasing emissions again " .. miningPollutionScale .. "x"))
			end
			--log(serpent.block(extraPollution[label]))
			if extraPollution[label] and extraPollution[label][k] then
				local f = extraPollution[label][k]
				obj.energy_source.emissions = obj.energy_source.emissions*f
				--log(serpent.block("ID'ed 'extra' polluter '" .. k .. "', increasing emissions again " .. f .. "x"))
			end
			--log(serpent.block("Success"))
		else
			--log(serpent.block("Entity had no emissions parameter. Entity: "))
			--log(serpent.block(obj))
		end
	end
end

for k,obj in pairs(data.raw.fire) do
	--log(serpent.block("Checking candidate polluter '" .. k .. "'"))
	--log(serpent.block("ID'ed polluter '" .. k .. "', increasing emissions " .. pollutionScale*firePollutionScale .. "x"))
	obj.emissions_per_tick = obj.emissions_per_tick*pollutionScale*firePollutionScale
	--log(serpent.block("Success"))
end

table.insert(data.raw.technology["circuit-network"].effects, {type="unlock-recipe", recipe="pollution-detector"})
table.insert(data.raw.technology["advanced-electronics"].effects, {type="unlock-recipe", recipe="gas-boiler"})
table.insert(data.raw.technology["advanced-material-processing"].effects, {type="unlock-recipe", recipe="steam-furnace"})

if data.raw.item.glass then
	table.insert(data.raw.recipe.greenhouse.ingredients, {"glass", 30})
end

--[[
table.insert(data.raw.technology["advanced-material-processing"].effects, {type="unlock-recipe", recipe="steam-furnace-flipped"})

local base = data.raw["assembling-machine"]["steam-furnace"]
local flipsteam = table.deepcopy(base)
flipsteam.name = flipsteam.name .. "-flipped"
flipsteam.localised_name = base.localised_name
flipsteam.fluid_boxes[1].pipe_connections[1] = {type = "input", positions = {{-0.5, -1.5}, {1.5, 0.5}, {-0.5, 1.5}, {-1.5, 0.5}}}

data:extend({
	flipsteam
})
--]]