require "config"
require "constants"

require "__DragonIndustries__.mathhelper"
require "__DragonIndustries__.arrays"
require "__DragonIndustries__.interpolation"
require "__DragonIndustries__.biters"

function getDeaeroRecipeName(efficiency)
	return efficiency ~= 1 and ("air-cleaning-action-F" .. math.floor(efficiency*1000+0.5)) or "air-cleaning-action" --for backwards compat
end

function setPollutionAndEvoSettings(nvday)
	if not nvday.lastEvoValue then
		nvday.lastEvoValue = 0
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
	if spawner.type == "unit-spawner" then
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
	end
end

function noSignificantBuilding()
	for struct,num in pairs(attackGreenlightingTypes) do
		if game.entity_prototypes[struct] and game.forces.player.get_entity_count(struct) >= num then
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
		if  game.forces.enemy.evolution_factor < 0.01 and (tick < 18000--[[60*60*5--]] or game.forces.enemy.evolution_factor < 0.004 or (game.forces.player and noSignificantBuilding())) then --less than five minutes into the game, or basically no pollution emission/construction (0.4% evo)
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
		entity.surface.pollute(entity.position, --[[settings.global['pollution_intensity'].value * --]]200)
	end
end