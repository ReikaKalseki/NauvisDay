require "config"
require "constants"

function listHasValue(list, val)
	for _,entry in pairs(list) do
		if entry == val then return true end
	end
end

function directionToVector(dir)
	if dir == defines.direction.north then
		return {dx=0, dy=-1}
	elseif dir == defines.direction.south then
		return {dx=0, dy=1}
	elseif dir == defines.direction.east then
		return {dx=1, dy=0}
	elseif dir == defines.direction.west then
		return {dx=-1, dy=0}
	end
end

function getOppositeDirection(dir) --direction is a number from 0 to 7
	return (dir+4)%8
end

function getPerpendicularDirection(dir) --direction is a number from 0 to 7
	return (dir+2)%8
end

function getMaxEnemyWaveSize(evo)
	if evo <= 0 then
		return maxAttackSizeCurve[1][2]
	end
	local idx = 1
	while idx <= #maxAttackSizeCurve and maxAttackSizeCurve[idx][1] < evo do
		idx = idx+1
	end
	idx = idx-1
	--game.print("Evo of " .. evo .. " > idx= " .. idx .. ": " .. maxAttackSizeCurve[idx][1] .. "," .. maxAttackSizeCurve[idx][2] .. " & " .. maxAttackSizeCurve[idx+1][1] .. "," .. maxAttackSizeCurve[idx+1][2])
	local x1 = maxAttackSizeCurve[idx][1]
	local x2 = maxAttackSizeCurve[idx+1][1]
	local y1 = maxAttackSizeCurve[idx][2]
	local y2 = maxAttackSizeCurve[idx+1][2]
	return math.ceil(y1+(y2-y1)*((evo-x1)/(x2-x1)))
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

function getPossibleBiters(curve, evo)
	local ret = {}
	local totalWeight = 0
	for _,entry in pairs(curve) do
		local biter = entry.unit
		local vals = entry.spawn_points -- eg "{0.5, 0.0}, {1.0, 0.4}"
		for idx = 1,#vals do
			local point = vals[idx]
			local ref = point.evolution_factor
			local chance = point.weight
			if evo >= ref then
				local interp = 0
				if idx == #vals then
					interp = chance
				else
					interp = chance+(vals[idx+1].weight-chance)*(vals[idx+1].evolution_factor-ref)
				end
				if interp > 0 then
					table.insert(ret, {biter, interp+totalWeight})
					totalWeight = totalWeight+interp
					--game.print("Adding " .. biter .. " with weight " .. interp)
				end
				break
			end
		end
	end
	--game.print("Fake Evo " .. evo)
	--for i=1,#ret do game.print(ret[i][1] .. ": " .. ((i == 1 and 0 or ret[i-1][2]) .. " -> " .. ret[i][2])) end
	return ret, totalWeight
end

function selectWeightedBiter(biters, total)
	local f = math.random()*total
	local ret = "nil"
	local smallest = 99999999
	for i = 1,#biters do
		if f <= biters[i][2] and smallest > biters[i][2] then
			smallest = biters[i][2]
			ret = biters[i][1]
		end
	end
	--game.print("Selected " .. ret .. " with " .. f .. " / " .. total)
	return ret
end

function getSpawnedBiter(curve, evo)
	--game.print("Real Evo " .. evo)
	if math.random() < 0.5 then
		evo = evo-0.1
	end
	if math.random() < 0.25 then
		evo = evo-0.1
	end
	evo = math.max(evo, 0)
	local biters, total = getPossibleBiters(curve, evo)
	return selectWeightedBiter(biters, total)
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
			spawner.surface.create_entity{name=biter, position=pos, force = spawner.force}
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

function getWeightedRandom(vals)
	local sum = 0
	for _,entry in pairs(vals) do
		local weight = entry[1]
		sum = sum+weight
	end
	
	--Copied and Luafied from DragonAPI WeightedRandom
	local d = math.random()*sum;
	local p = 0
	for _,entry in pairs(vals) do
		p = p + entry[1]
		if d <= p then
			return entry[2]
		end
	end
	return nil
end

function checkPollutionBlock(entity)
	if entity.name == "pollution-block" then
		entity.surface.pollute(entity.position, --[[settings.global['pollution_intensity'].value * --]]200)
	end
end