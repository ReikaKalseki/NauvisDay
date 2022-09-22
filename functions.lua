require "config"
require "constants"

require "__DragonIndustries__.mathhelper"
require "__DragonIndustries__.arrays"
require "__DragonIndustries__.interpolation"
require "__DragonIndustries__.biters"
require "__DragonIndustries__.ores"
require "__DragonIndustries__.strings"
require "__DragonIndustries__.items"

function getDeaeroRecipeName(efficiency)
	--game.print("Efficiency is " .. efficiency)
	return efficiency ~= 1 and ("air-cleaning-action-F" .. math.floor(efficiency*1000+0.5)) or "air-cleaning-action" --for backwards compat
end

local function getAmountProduced(force, item)
	if game.item_prototypes[item] == nil then return 0 end
	local form = getItemType(item)
	local stats = form == "fluid" and force.fluid_production_statistics or force.item_production_statistics
	return stats.get_flow_count{name = item, input=true, precision_index=defines.flow_precision_index.ten_minutes}
end

local function hasNoMining()
	local names = getAllOreDrops()
	local force = game.forces.player
	for _,item in pairs(names) do
		local prod = getAmountProduced(force, item)
		if item == stone then --too many things produce it as a byproduct
			prod = 0
		end
		--game.print(item .. " > " .. prod)
		--if prod > 0 then return false end
	end
	return true
end

function setPollutionAndEvoSettings(nvday)
	if not nvday.lastEvoValue then
		nvday.lastEvoValue = 0
	end
	if not nvday.evoTimePenalty then
		nvday.evoTimePenalty = 1
	end
	if not nvday.evotimebonus then
		nvday.evotimebonus = 1
	end
	local delta = game.forces.enemy.evolution_factor-nvday.lastEvoValue
	nvday.lastEvoValue = game.forces.enemy.evolution_factor
	if delta < 0 then
		nvday.evotimebonus = math.min(20, nvday.evotimebonus*1.025) --this runs once a minute, so it reaches 10x around 90 min and the max of 20x after about 2h
	else
		nvday.evotimebonus = 1
	end
	
	local total = game.map_settings
	local settings = game.surfaces["nauvis"].map_gen_settings
	
	local timefac = 1
	if settings.width > 0 and settings.width < 500 then
		local f = settings.width < 200 and 3 or 1.5
		timefac = timefac*f
	end
	if settings.height > 0 and settings.height < 500 then
		local f = settings.height < 200 and 3 or 1.5
		timefac = timefac*f
	end
	if nvday.evotimebonus > 1 then
		timefac = timefac*nvday.evotimebonus
	end
	if nvday.evoTimePenalty < 1 and game.tick-nvday.lastSpawnerKill > 60 then --spawner-kill penalty active and >= 1s since last spawner death
		nvday.evoTimePenalty = math.min(1, nvday.evoTimePenalty*1.35) --approx 10 minutes for evo time factor to recover from its 0.04x
		--game.print("Evo time penalty increased to: " .. nvday.evoTimePenalty)
	else
		--game.print("Evo time penalty static at: " .. nvday.evoTimePenalty)
	end
	timefac = timefac*nvday.evoTimePenalty
	
	if hasNoMining() then
		--game.print("Mining is disabled. Evo time fac goes from " .. timefac .. " to " .. (timefac*noMiningCalmingFactor))
		timefac = timefac*noMiningCalmingFactor
	end
	for name,val in pairs(decorativeModPollutionScales) do
		if game.active_mods[name] then
			timefac = timefac/val
		end
	end
	
	for category, params in pairs(pollutionAndEvo) do
		for entry, val in pairs(params) do
			if type(val) == "table" then
				val = val[game.difficulty_settings.recipe_difficulty == defines.difficulty_settings.recipe_difficulty.normal and 1 or 2]
			end
			local output = true
			if category == "enemy_evolution" and entry == "time_factor" and timefac > 1 then
				val = val*timefac
				output = false
				--game.print(timefac .. " -> " .. val)
			end
			--game.print("Checking param " .. entry .. "...map val = " .. total[category][entry] .. ", target = " .. val)
			if total[category][entry] ~= val then
				if output then
					game.print("NauvisDay: Re-setting " .. category .. "." .. entry .. " to " .. val .. " (was " .. total[category][entry] .. ")")
				end
				total[category][entry] = val
			end
		end
	end
	if game.surfaces["nauvis"].peaceful_mode or settings.peaceful_mode then
		game.print("NauvisDay: Disabling peaceful mode.")
	end
	game.surfaces["nauvis"].peaceful_mode = false
	settings.peaceful_mode = false
	--game.surfaces["nauvis"].autoplace_controls
end

function doTreeFarmTreeDeath(entity)
	--game.print(entity.name .. " & " .. (entity.type == "tree" and "true" or " false") .. " & " .. (string.find(entity.name, "tree") and "true" or " false") .. " & " .. (string.find(entity.name, "tf-", 1, true) and "true" or " false"))
	if entity.type == "tree" and string.find(entity.name, "tree") and string.find(entity.name, "tf-", 1, true) then
		local ret = entity.surface.create_entity({name="dead-tf-tree", position={entity.position.x, entity.position.y}, direction=entity.direction, force=entity.force})
	end
end

function doSpawnerDestructionSpawns(spawner)
	if spawner.type == "unit-spawner" and spawner.force == game.forces.enemy then
		local num = math.random(2, 20)
		for i = 1,num do
			local pos = {spawner.position.x, spawner.position.y}
			local data = spawner.prototype.result_units--game.entity_prototypes[spawner.type][spawner.name]--spawner.prototype
			local r = 10--data.spawning_radius
			pos[1] = pos[1]-r+math.random()*2*r
			pos[2] = pos[2]-r+math.random()*2*r
			local biter = getSpawnedBiter(data, spawner.force.evolution_factor)
			if spawner.surface.can_place_entity{name = biter, position = pos} then
				spawner.surface.create_entity{name=biter, position=pos, force = spawner.force}
			end
		end
		local nvday = global.nvday
		nvday.lastSpawnerKill = game.tick
		nvday.evoTimePenalty = 0.04
		--game.print("Setting evo time penalty static at: " .. nvday.evoTimePenalty)
		setPollutionAndEvoSettings(nvday)
		nvday.evotimebonus = 1 --reset
	end
end

function noSignificantBuilding()
	for struct,num in pairs(attackGreenlightingTypes) do
		local num2 = game.active_mods["EarlyExtensions"] and math.floor(num*1.5) or num
		--game.print(struct .. " > " .. game.forces.player.get_entity_count(struct) .. " / " .. num2);
		if game.entity_prototypes[struct] and game.forces.player.get_entity_count(struct) >= num2 then
			return false
		end
	end
	return true
end

function playerNearSpawner()
	for _,player in pairs(game.players) do
		local nearspawner = player.surface.find_nearest_enemy{position=player.position, max_distance = 45, force = player.force}
		if nearspawner then
			return true
		end
	end
	return false
end

function ensureNoEarlyAttacks(tick)
	--game.map_settings.unit_group.max_gathering_unit_groups = 2 --default 30
	--game.map_settings.unit_group.max_unit_group_size = 5 --default 200
	--game.map_settings.unit_group.min_group_gathering_time = 3600*5 --default 3600=60s
	--game.map_settings.unit_group.max_group_gathering_time = game.map_settings.unit_group.min_group_gathering_time*10 --default 10x min
	if tick%1800 == 0 then --once per 30s
		if game.forces.enemy.evolution_factor < 0.01 and (tick < 18000--[[60*60*5--]] or game.forces.enemy.evolution_factor < 0.004 or (game.forces.player and noSignificantBuilding())) then --less than five minutes into the game, or basically no pollution emission/construction (0.4% evo)
			--set peaceful mode until some threshold tick? or built some structures
			--or try destroy units, or max size of attack = 0 -> modify map_settings.unit group to change attacks, but problem is will probably result in MASSIVE first attack; would also conflict with NatEvo
			if not playerNearSpawner() then
				game.forces.enemy.kill_all_units()
			end
		end
	end
end

function checkPollutionBlock(entity)
	if entity.name == "pollution-block" then
		entity.surface.pollute(entity.position, --[[settings.global['pollution_intensity'].value * --]]500)
	end
end

function upgradeStorageMachine(entity)
	local pos = entity.position
	local force = entity.force
	local dir = entity.direction
	local surf = entity.surface
	entity.destroy()
	return surf.create_entity{name = "storage-machine-2", force = force, direction = dir, position = pos}
end