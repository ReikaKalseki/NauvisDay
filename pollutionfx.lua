require "constants"
require "functions"

function tickSpill(entry, nvday, doText, simulate)
	local f = liquidPollutionFactors[entry.fluid]
	local f2 = liquidEvaporationFactors[entry.fluid]
	if not f then f = 1 end
	if not f2 then f2 = 1 end
	local amt = math.max(1, math.floor(f2*entry.amount/64))
	local pol = math.floor(amt*f+0.5)
	
	entry.lastemit = pol*4 --per-second pollution emission
	entry.lastevap = amt*4
	
	if not simulate then
		entry.entity.surface.pollute(entry.entity.position, pol)
		entry.amount = entry.amount-amt
		entry.age = entry.age+1
		
		--game.print("Evaporating " .. amt .. " of " .. entry.fluid .. " into " .. pol .. " pollution; " .. entry.amount .. " remaining")
		--[[if doText then
			entry.entity.surface.create_entity({name = "flying-text", position = entry.entity.position, force=game.forces.neutral, text = "Evaporating " .. amt .. " of " .. entry.fluid .. " into " .. pol .. " pollution; " .. entry.amount .. " remaining"})
		end--]]
		if entry.amount <= 0 then
			nvday.spills[entry.key] = nil
	
			for _,player in pairs(game.players) do
				if player.selected == entry.entity then
					setSpillGui(player, nil)
				end
			end
			
			entry.entity.destroy()
		else
			setSpillStage(entry)
			
			if doText and entry.gui then
				for _,elem in pairs(entry.gui) do
					elem.caption = getSpillTooltip(entry)
				end
			end
			if liquidDamageLevels[entry.fluid] then
				for _,player in pairs(game.players) do
					if player.character then -- MP players not currently logged in do not have chars
						if math.abs(player.character.position.x-entry.entity.position.x) <= 3 and math.abs(player.character.position.y-entry.entity.position.y) <= 3 then
							player.character.damage(liquidDamageLevels[entry.fluid], game.forces.neutral)
						end
					end
				end
			end
		end
	end
end

function tickSpilledFluids(nvday, doText)
	for _,entry in pairs(nvday.spills) do
		if entry.entity.valid then
			tickSpill(entry, nvday, doText, false)
		else
			nvday.spills[entry.key] = nil
		end
	end
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
	local cloud = getPollutionFogSize(pollution)
	if cloud then
		surface.create_entity({name="pollution-fog-" .. cloud, position=pos, force = game.forces.neutral})
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
			table.insert(tile_changes, {name=newtile, position={dx, dy}})
			local pumps = surface.find_entities_filtered({area = {{dx-2, dy-2}, {dx+2, dy+2}}, type = "offshore-pump"})
			for _,pump in pairs(pumps) do
				if string.find(pump.name, "polluted") then
					pump.surface.create_entity{name=string.sub(pump.name, sublen), position=pump.position, force = pump.force, direction = pump.direction, fast_replace = true, spill = false}
					pump.destroy()
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
	if pollution <= 0 then
		return false
	end
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
		surface.set_tiles(tile_changes)
	end
	return true
end

function doAmbientPollutionEffects(nvday, tick)
	local fog = math.random() < 0.01
	if #game.players > 0 and fog then
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
			local s = 8
			local dx = math.random(0, 32-s)
			local dy = math.random(0, 32-s)
			local x = chunk.x*32+dx
			local y = chunk.y*32+dy
			local area = {{x, y}, {x+s, y+s}}
			if destroyTreeFarms(surface, area, tick) then
				return
			end
			trySpawnNuker(surface, x, y, s)
		end
		if k >= tries or doWaterPollution(surface, chunk, tick) then
			return
		end
		k = k+1
	end
end