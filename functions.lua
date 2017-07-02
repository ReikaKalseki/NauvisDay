require "config"
require "constants"

function onFirstTick(tick)
	setPollutionAndEvoSettings()
end

function setPollutionAndEvoSettings()
	for category, params in pairs(pollutionAndEvo) do
		for entry, val in pairs(params) do
			if game.map_settings[category][entry] ~= val then
				game.print("NauvisDay: Re-setting " .. category .. "." .. entry .. " to " .. val .. " (was " .. game.map_settings[category][entry] .. ")")
				game.map_settings[category][entry] = val
			end
		end
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

function doWaterPollution(tick)
	if tick%60 == 0 then
		tick = tick/60
		local i = 0
		local surface = game.surfaces["nauvis"]
		local chunks = surface.get_chunks()
		for chunk in chunks do
			tickChunkPollution(surface, chunk, tick, i)
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

function tickChunkPollution(surface, chunk, tick, i)
	--game.print(tick .. ", " .. #chunks .. ", " .. tick%(#chunks))
	--if tick%(#chunks) == 0 then
	local x1 = chunk.x*32
	local y1 = chunk.y*32
	local x2 = x1+32
	local y2 = y1+32
	local x = math.random(x1,x2)
	local y = math.random(y1,y2)
	local shape = getWeightedRandom(waterConversionPatterns)
	local row = #shape
	local col = #(shape[1])
	for i = 1,col do
		for k = 1,row do
			if shape[i][k] == 1 then
				tickBlockPollution(surface, chunk, tick, x+i-col/2, y+k-row/2)
			end
		end
	end
	--end
	--i = i+1
end

function tickBlockPollution(surface, chunk, tick, dx, dy)
	local pollution = surface.get_pollution({dx,dy})
	local tile = surface.get_tile(dx, dy)
	--game.print(dx .. "," .. dy .. ", " .. pollution .. " & " .. tile.name)
	if pollution > Config.pollutedWaterThreshold then --make heavily polluted areas cause water pollution and remove some air pollution
		if tile.name == "water" or tile.name == "water-green" or tile.name == "deepwater" or tile.name == "deepwater-green" then
			surface.set_tiles({{name="polluted-" .. tile.name, position={dx, dy}}})
			local pumps = surface.find_entities_filtered({area = {{dx-2, dy-2}, {dx+2, dy+2}}, type = "offshore-pump"}) --need to also convert offshore pumps into nonfunctional variants that still drop offshore pumps
			for _,pump in pairs(pumps) do
				if not string.find(pump.name, "polluted") then
					pump.surface.create_entity{name="polluted-" .. pump.name, position=pump.position, force = pump.force, direction = pump.direction, fast_replace = true, spill = false}
					pump.destroy()
				end
			end
			surface.pollute({dx, dy}, -Config.pollutedWaterTileCleanup)
		end				
	end
	if pollution < Config.cleanWaterThreshold then --also convert back if pollution is mostly gone, though add some air pollution to do so
		if tile.name == "polluted-water" or tile.name == "polluted-water-green" or tile.name == "polluted-deepwater" or tile.name == "polluted-deepwater-green" then
			local sublen = 1+string.len("polluted-");
			local newtile = string.sub(tile.name, sublen)
			--game.print(tile.name .. " > " .. newtile)
			surface.set_tiles({{name=newtile, position={dx, dy}}})
			local pumps = surface.find_entities_filtered({area = {{dx-2, dy-2}, {dx+2, dy+2}}, type = "offshore-pump"})
			for _,pump in pairs(pumps) do
				if string.find(pump.name, "polluted") then
					pump.surface.create_entity{name=string.sub(pump.name, sublen), position=pump.position, force = pump.force, direction = pump.direction, fast_replace = true, spill = false}
					pump.destroy()
				end
			end
			surface.pollute({dx, dy}, Config.pollutedWaterTileCleanup)
		end		
	end
end

function fluidSpill(e)
	if #e.fluidbox > 0 then
		for b = 1, #e.fluidbox do
		  if e.fluidbox[b] and e.fluidbox[b].type == "waste" then
			local spill_amount = e.fluidbox[b].amount
			-- debug("pollute! " .. position.x .. "," .. position.y .. " " .. corpse_size * settings.global['pollution_intensity'].value * spill_amount * 20)
			e.surface.pollute(e.position, --[[settings.global['pollution_intensity'].value * --]]spill_amount * 20)
		  end
		end
	end
end

function checkPollutionBlock(entity)
	if entity.name == "pollution-block" then
		entity.surface.pollute(entity.position, --[[settings.global['pollution_intensity'].value * --]]200)
	end
end

--[[
function convertDepletedOilToWasteWell(e)
	if e.name == "storage-machine" then
		local oil = e.surface.find_entities_filtered({area = {{e.position.x-0.5, e.position.y-0.5}, {e.position.x+0.5, e.position.y+0.5}}, type="resource", name="crude-oil"})
		local patch = oil[1]
		if not patch then return end
		--patch.amount = patch.prototype.infinite_resource and 10 or 1
		if patch.amount > (patch.prototype.infinite_resource and 10 or 1) then --not depleted
			e.surface.spill_item_stack(e.position, {name=e.prototype.mineable_properties.products[1].name}, true)
			e.destroy()
			return
		end
		e.surface.create_entity{name="pollution-well", position=e.position, amount=patch.amount}
		patch.destroy()
		--replace well
		e.surface.create_entity{name=e.name, position=e.position, direction=e.direction, force=e.force, fast_replace=true, spill=false}
		e.destroy()
	end
end

function convertWasteWellToDepletedOil(e)
	if e.name == "storage-machine" then
		local well = e.surface.find_entities_filtered({area = {{e.position.x-0.5, e.position.y-0.5}, {e.position.x+0.5, e.position.y+0.5}}, name="pollution-well"})
		local patch = well[1]
		if not patch then return end
		e.surface.create_entity{name="crude-oil", position=e.position, amount=patch.amount}
		patch.destroy()
	end
end
--]]