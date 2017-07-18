function canPlaceAt(surface, x, y)
	return surface.can_place_entity{name = "tectonic-well", position = {x, y}} and not isWaterEdge(surface, x, y)
end

function isWaterEdge(surface, x, y)
	if surface.get_tile{x-1, y}.valid and surface.get_tile{x-1, y}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x+1, y}.valid and surface.get_tile{x+1, y}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x, y-1}.valid and surface.get_tile{x, y-1}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x, y+1}.valid and surface.get_tile{x, y+1}.prototype.layer == "water-tile" then
		return true
	end
end

function isInChunk(x, y, chunk)
	local minx = math.min(chunk.left_top.x, chunk.right_bottom.x)
	local miny = math.min(chunk.left_top.y, chunk.right_bottom.y)
	local maxx = math.max(chunk.left_top.x, chunk.right_bottom.x)
	local maxy = math.max(chunk.left_top.y, chunk.right_bottom.y)
	return x >= minx and x <= maxx and y >= miny and y <= maxy
end

function createWell(surface, chunk, dx, dy)
	if --[[isInChunk(dx, dy, chunk) and ]]canPlaceAt(surface, dx, dy) then
		surface.create_entity{name = "tectonic-well", position = {x = dx, y = dy}, force = game.forces.neutral, amount = 1}
		game.print("Placing at " .. dx .. ", " .. dy)
	end
end

function cantorCombine(a, b)
	--a = (a+1024)%16384
	--b = b%16384
	local k1 = a*2
	local k2 = b*2
	if a < 0 then
		k1 = a*-2-1
	end
	if b < 0 then
		k2 = b*-2-1
	end
	return 0.5*(k1 + k2)*(k1 + k2 + 1) + k2
end

function createSeed(surface, x, y) --Used by Minecraft MapGen
	return bit32.band(cantorCombine(surface.map_gen_settings.seed, cantorCombine(x, y)), 2147483647)
end

function generateEmptyWells(surface, area, x, y, rand)
	--[[ --Random patches
	local count = rand(12, 24)
	for i = 0, count do
		local dx = x-16+rand(0, 32)
		local dy = y-16+rand(0, 32)
		createWell(surface, area, dx, dy)
	end
	--]]
	 --'Ravines'
	local ang = (rand(0, 2147483647)/2147483647)*360
	local len = rand(60,120) --was 8-16, then 12-40, then 24-60, then 40-70, then 80-200
	
	local x1 = x-len/2*math.cos(ang)
	local y1 = y-len/2*math.sin(ang)
	local x2 = x+len/2*math.cos(ang)
	local y2 = y+len/2*math.sin(ang)
	
	for dx = x1,x2 do
		for dy = y1,y2 do
			local ang0 = math.atan2(dy-y1, dx-x1)*180/math.pi
			local da = math.abs(ang0-ang)
			local maxda = rand(8,12)
			if da < maxda and (rand(0, 2147483647)/2147483647) > 0.7 then
				createWell(surface, area, dx, dy)
			end
		end
	end
	--[[
	local f = 1--4 --granularity increase; += decimal does not work well
	for d = -len/2*f,len/2*f do
		local da = 1--(1-math.abs(d/(len/2*f)))*5
		local ang0 = ang-da+(rand(0, 2147483647)/2147483647)*da*2
		local dx = x+math.ceil(d/f*math.cos(ang0))
		local dy = y+math.ceil(d/f*math.sin(ang0))
		
		createWell(surface, area, dx, dy)
	end
	--]]
	
end