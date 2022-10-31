require "constants"
require "functions"

local function getAcidFogSize(pollution)
	local ratio = pollution/Config.acidRainThreshold
	if ratio < 1 then
		return nil
	end
	if ratio <= acidFogSizes[1][1] then
		if math.random(0, acidFogSizes[1][1]) < ratio then
			return acidFogSizes[1][2]
		else
			return nil
		end
	end
	if ratio >= acidFogSizes[#acidFogSizes][1] then
		return acidFogSizes[#acidFogSizes-1][2]
	end
	local idx = 1
	while idx <= #acidFogSizes and acidFogSizes[idx][1] < ratio do
		idx = idx+1
	end
	idx = idx-1
	if idx == 1 then
		return acidFogSizes[1][2]
	end
	--game.print("Pollution of " .. pollution .. " > idx= " .. idx .. ": " .. acidFogSizes[idx-1][1] .. "," .. acidFogSizes[idx-1][2] .. " & " .. acidFogSizes[idx][1] .. "," .. acidFogSizes[idx][2])
	local x1 = acidFogSizes[idx][1]
	local x2 = acidFogSizes[idx+1][1]
	local y1 = acidFogSizes[idx-1][2]
	local y2 = acidFogSizes[idx][2]
	local f = math.random()
	--local ret = f < (pollution-x1)/(x2-x1) and y2 or y1
	--game.print(f .. " of " .. (pollution-x1)/(x2-x1) .. " > " .. ret)
	return f < (ratio-x1)/(x2-x1) and y2 or y1
end

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
	if pollution >= pollutionFogSizes[#pollutionFogSizes][1] then
		return pollutionFogSizes[#pollutionFogSizes-1][2]
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
	--local ret = f < (pollution-x1)/(x2-x1) and y2 or y1
	--game.print(f .. " of " .. (pollution-x1)/(x2-x1) .. " > " .. ret)
	return f < (pollution-x1)/(x2-x1) and y2 or y1
end

local function spawnPollutionSmoke(pos, surface)
	if not pos then
		local player = game.players[math.random(1, #game.players)]
		surface = player.surface
		pos = {}
		pos.x = player.position.x+math.random(-100, 100)
		pos.y = player.position.y+math.random(-100, 100)
	end
	local pollution = surface.get_pollution(pos)
	--game.print(pollution .. " / " .. Config.acidRainThreshold .. " > f = " .. (Config.acidRainThreshold/pollution))
	if pollution >= Config.acidRainThreshold and math.random() > Config.acidRainThreshold/pollution then -- so a 1/N chance where N is the number of times the pollution is of the threshold
		local acid = getAcidFogSize(pollution)
		if acid then
			surface.create_entity({name="acid-rain-" .. acid, position=pos, force = game.forces.neutral})
		end
	else
		local cloud = getPollutionFogSize(pollution)
		if cloud then
			surface.create_entity({name="pollution-fog-" .. cloud, position=pos, force = game.forces.neutral})
		end
	end
end

local function killTreefarm(farm, newname)
	local pos = farm.position
	local force = farm.force
	local dir = farm.direction
	local rec = farm.get_recipe()
	local surface = farm.surface
	for _,player in pairs(force.players) do
		player.add_alert(farm, defines.alert_type.entity_destroyed)
	end
	local items = {}
	for item,amount in pairs(farm.get_output_inventory().get_contents()) do
		items[item]=amount
	end
	farm.die()
	local new = surface.create_entity({name=newname, position=pos, force = force, direction=dir, fast_replace=true})
	local put = new.set_recipe(rec)
	for type,amt in pairs(items) do
		surface.spill_item_stack(pos, {name = type, count = amt}, true, force)
	end
	for type,amt in pairs(put) do
		surface.spill_item_stack(pos, {name = type, count = amt}, true, force)
	end
	new.burner.currently_burning = game.item_prototypes["rocket-fuel"]
	new.burner.remaining_burning_fuel = 100000000000
	new.operable = false
	flag = true
	spawnPollutionSmoke(pos, surface)
end

local function destroyTreeFarms(surface, _area, tick) --TreeFarm mod, Greenhouses, and BioIndustries
	--Treefarm is already handled by pollution clouds
	
	local pollution = surface.get_pollution({math.random(_area[1][1], _area[2][1]), math.random(_area[1][2], _area[2][2])})
	if pollution > 40000 and math.random(40000, 120000) < pollution then
		local flag = false
		local farms = surface.find_entities_filtered({name="bi_bio_farm", area = _area})
		for _,farm in pairs(farms) do
			killTreefarm(farm, "dead-bio-farm")
		end
		
		farms = surface.find_entities_filtered({name="bob-greenhouse", area = _area})
		for _,farm in pairs(farms) do
			killTreefarm(farm, "dead-greenhouse")
		end
	end
	
	return flag
end

function tickBlockPollution(surface, chunk, tick, dx, dy, tile_changes)
	local pollution = surface.get_pollution({dx,dy})
	local tile = surface.get_tile(dx, dy)
	--game.print(dx .. "," .. dy .. ", " .. pollution .. " & " .. tile.name)
	if pollution > Config.pollutedWaterThreshold then --make heavily polluted areas cause water pollution and remove some air pollution
		if tile.name == "water" or tile.name == "water-green" or tile.name == "deepwater" or tile.name == "deepwater-green" then
			--game.print("Converting water @ " .. dx .. "," .. dy .. ", pollution = " .. pollution)
			table.insert(tile_changes, {name="polluted-" .. tile.name, position={dx, dy}})
			local pumps = surface.find_entities_filtered({area = {{dx-2, dy-2}, {dx+2, dy+2}}, type = "offshore-pump"}) --need to also convert offshore pumps into nonfunctional variants that still drop offshore pumps
			for _,pump in pairs(pumps) do
				if not string.find(pump.name, "polluted") then
					local new = pump.surface.create_entity{name="polluted-" .. pump.name, position=pump.position, force = pump.force, direction = pump.direction, fast_replace = true, spill = false}
					pump.destroy()
					new.active = false
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
			table.insert(tile_changes, {name=newtile, position={dx, dy}})
			local pumps = surface.find_entities_filtered({area = {{dx-2, dy-2}, {dx+2, dy+2}}, type = "offshore-pump"})
			for _,pump in pairs(pumps) do
				if string.find(pump.name, "polluted") then
					local new = pump.surface.create_entity{name=string.sub(pump.name, sublen), position=pump.position, force = pump.force, direction = pump.direction, fast_replace = true, spill = false}
					pump.destroy()
					new.active = true
				end
			end
			surface.pollute({dx, dy}, Config.pollutedWaterTileCleanup*Config.pollutedWaterTileRelease)
		end		
	end
end

function doWaterPollution(surface, chunk, tick)
	local x1 = chunk.x*32
	local y1 = chunk.y*32
	local x2 = x1+32
	local y2 = y1+32
	local x = math.random(x1,x2)
	local y = math.random(y1,y2)
	local pollution = surface.get_pollution({x,y})
	local tile_changes = {}
	local shape = getWeightedRandom(waterConversionPatterns)
	local col = #shape
	local row = #(shape[1])
	for i = 1,col do
		for k = 1,row do
			if shape[i][k] == 1 then
				--for a = -1,1 do for b = -1,1 do
					tickBlockPollution(surface, chunk, tick, x+i-col/2, y+k-row/2, tile_changes)
				--end end
			end
		end
	end
	if #tile_changes > 0 then
		for _,change in ipairs(tile_changes) do
			if change and not change.position.x and change.position[1] then
				change.position.x = change.position[1]
				change.position.y = change.position[2]
			end
			if not (change and change.position and change.position.x and change.position.y) then
				game.print("Got invalid tile change @ " .. serpent.block(change))
			else
				local at = surface.get_tile(change.position.x, change.position.y)
				if at and at.valid then
					surface.set_hidden_tile(change.position, at.name)
				end
			end
		end
		surface.set_tiles(tile_changes)
	end
	return true
end

function doAmbientPollutionEffects(nvday, tick)
	local fog = math.random() < 0.01
	if #game.players > 0 and fog then
		spawnPollutionSmoke()
	end
	local sp = 1--20--60
	if true then -- tick%sp == 0 then
		local surface = getRandomTableEntry(game.surfaces)--game.surfaces["nauvis"]
		local tries = 25--20--8
		local k = 0
		--tick = math.floor(tick/sp)
		--game.print("Picking chunk " .. idx .. " of " .. n ..", = " .. chunk.x .. "," .. chunk.y .. "; attempt " .. k)
		local chunk = surface.get_random_chunk()
		if k == 0 then
			local s = 8
			local dx = math.random(0, 32-s)
			local dy = math.random(0, 32-s)
			local x = chunk.x*32+dx
			local y = chunk.y*32+dy
			local chunkarea = {{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}
			local area = {{x, y}, {x+s, y+s}}
			if destroyTreeFarms(surface, area, tick) then
				return
			end
			trySpawnNuker(surface, x, y, s)
			local pos = {dx, dy}
			local decos = surface.find_decoratives_filtered{area = chunkarea}
			local df = -0.04
			local dp = math.min(#decos*df, math.floor(surface.get_pollution(pos)*0.04))
			--game.print(#decos .. " causes " .. dp .. " pollution")
			surface.pollute(pos, dp)
		end
		if k >= tries or doWaterPollution(surface, chunk, tick) then
			return
		end
		k = k+1
	end
end