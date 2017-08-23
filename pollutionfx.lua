require "constants"

local function getPollutionFogSize(pollution)
	if pollution <= 0 then
		return nil
	end
	if pollution <= pollutionFogSizes[1][1] then
		if math.random(0, pollutionFogSizes[1][1]) < pollution then
			return pollutionFogSizes[1][2]
		else
			return nil
		end
	end
	local idx = 1
	while idx <= #pollutionFogSizes and pollutionFogSizes[idx][1] < pollution do
		idx = idx+1
	end
	idx = idx-1
	if idx == 1 then
		return pollutionFogSizes[1][2]
	end
	--game.print("Pollution of " .. pollution .. " > idx= " .. idx .. ": " .. pollutionFogSizes[idx-1][1] .. "," .. pollutionFogSizes[idx-1][2] .. " & " .. pollutionFogSizes[idx][1] .. "," .. pollutionFogSizes[idx][2])
	local x1 = pollutionFogSizes[idx][1]
	local x2 = pollutionFogSizes[idx+1][1]
	local y1 = pollutionFogSizes[idx-1][2]
	local y2 = pollutionFogSizes[idx][2]
	local f = math.random()
	local ret = f < (pollution-x1)/(x2-x1) and y2 or y1
	--game.print(f .. " of " .. (pollution-x1)/(x2-x1) .. " > " .. ret)
	return f < (pollution-x1)/(x2-x1) and y2 or y1
end

local function spawnPollutionSmoke()
	local player = game.players[math.random(1, #game.players)]
	local surface = player.surface
	local pos = {x=player.position.x+math.random(-100, 100), y=player.position.y+math.random(-100, 100)}
	local pollution = surface.get_pollution(pos)
	local cloud = getPollutionFogSize(pollution)
	if cloud then
		surface.create_entity({name="pollution-fog-" .. cloud, position=pos, force = game.forces.neutral})
	end
end

local function destroyTreeFarms(surface, chunk, tick) --TreeFarm mod, Greenhouses, and BioIndustries
	--Treefarm is already handled by pollution clouds
	
	local _area = {{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}
	local pollution = surface.get_pollution({math.random(_area[1][1], _area[2][1]), math.random(_area[1][2], _area[2][2])})
	if pollution > 40000 and math.random(40000, 120000) < pollution then
		local flag = false
		local farms = surface.find_entities_filtered({name="bi_bio_farm", area = _area})
		for _,farm in pairs(farms) do
			local pos = farm.position
			local force = farm.force
			local dir = farm.direction
			local rec = farm.recipe
			farm.die()
			local new = surface.create_entity({name="dead-bio-farm", position=pos, force = force, direction=dir})
			new.recipe = rec
			new.burner.currently_burning = game.item_prototypes["rocket-fuel"]
			new.burner.remaining_burning_fuel = 100000000000
			new.operable = false
			flag = true
		end
		
		farms = surface.find_entities_filtered({name="bob-greenhouse", area = _area})
		for _,farm in pairs(farms) do
			local pos = farm.position
			local force = farm.force
			local dir = farm.direction
			local rec = farm.recipe
			farm.die()
			local new = surface.create_entity({name="dead-greenhouse", position=pos, force = force, direction=dir})
			new.recipe = rec
			new.burner.currently_burning = game.item_prototypes["rocket-fuel"]
			new.burner.remaining_burning_fuel = 100000000000
			new.operable = false
			flag = true
		end
	end
	
	return flag
end

function doWaterPollution(surface, chunk, tick)
	local x1 = chunk.x*32
	local y1 = chunk.y*32
	local x2 = x1+32
	local y2 = y1+32
	local x = math.random(x1,x2)
	local y = math.random(y1,y2)
	local pollution = surface.get_pollution({x,y})
	if pollution <= 0 then
		return false
	end
	local shape = getWeightedRandom(waterConversionPatterns)
	local col = #shape
	local row = #(shape[1])
	for i = 1,col do
		for k = 1,row do
			if shape[i][k] == 1 then
				--for a = -1,1 do for b = -1,1 do
					tickBlockPollution(surface, chunk, tick, x+i-col/2, y+k-row/2)
				--end end
			end
		end
	end
	return true
end

function tickBlockPollution(surface, chunk, tick, dx, dy)
	local pollution = surface.get_pollution({dx,dy})
	local tile = surface.get_tile(dx, dy)
	--game.print(dx .. "," .. dy .. ", " .. pollution .. " & " .. tile.name)
	if pollution > Config.pollutedWaterThreshold then --make heavily polluted areas cause water pollution and remove some air pollution
		if tile.name == "water" or tile.name == "water-green" or tile.name == "deepwater" or tile.name == "deepwater-green" then
			--game.print("Converting water @ " .. dx .. "," .. dy .. ", pollution = " .. pollution)
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

function doAmbientPollutionEffects(nvday, tick)
	if #game.players > 0 and math.random() < 0.01 then
		spawnPollutionSmoke()
	end
	local n = #nvday.chunk_cache
	local sp = 1--20--60
	if n > 0 and tick%sp == 0 then
		local surface = game.surfaces["nauvis"]
		local tries = 20--8
		local k = 0
		--tick = math.floor(tick/sp)
		local idx = math.random(1, n)--tick%n
		--game.print("Picking chunk " .. idx .. " of " .. n ..", = " .. chunk.x .. "," .. chunk.y .. "; attempt " .. k)
		local chunk = nvday.chunk_cache[idx]
		if k == 0 then
			if destroyTreeFarms(surface, chunk, tick) then
				return
			end
		end
		if k >= tries or doWaterPollution(surface, chunk, tick) then
			return
		end
		k = k+1
	end
end