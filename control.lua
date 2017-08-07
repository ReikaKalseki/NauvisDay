require "functions"
require "constants"
require "config"

require "wellgen"
require "pollutiondetection"

require "entitytracker"

function initGlobal(force)
	if not global.nvday then
		global.nvday = {}
	end
	if force or global.nvday.loadTick == nil then
		global.nvday.loadTick = false
	end
	if force or global.nvday.chunk_cache == nil then
		global.nvday.chunk_cache = {}
	end
	if force or global.nvday.pollution_detectors == nil then
		global.nvday.pollution_detectors = {}
	end
	if force or global.nvday.gas_boilers == nil then
		global.nvday.gas_boilers = {}
	end
	if force or global.nvday.steam_furnaces == nil then
		global.nvday.steam_furnaces = {}
	end
	if force or global.nvday.boreholes == nil then
		global.nvday.boreholes = {}
	end
	if force or global.nvday.borers == nil then
		global.nvday.borers = {}
	end
end

initGlobal(true)

script.on_init(function()
	initGlobal(true)
end)

script.on_configuration_changed(function()
	initGlobal(true)
	setPollutionAndEvoSettings()
end)

script.on_init(function()
	initGlobal(true)
	setPollutionAndEvoSettings()
end)

script.on_event(defines.events.on_console_command, function(event)
	setPollutionAndEvoSettings()
end)
--[[
local function onTilesBuilt(event)
	local surface = game.surfaces[event.surface_index]
	local positions = event.positions
	for _,pos in pairs(positions) do
	
	end
end
--]]
local function onEntityRotated(event)
	--convertDepletedOilToWasteWell(event.created_entity)
	rotateGasBoiler(event.entity)
end

local function onEntityAdded(event)
	--convertDepletedOilToWasteWell(event.created_entity)
	
	--[[
	addPollutionDetector(event.created_entity)
	addGasBoiler(event.created_entity)
	addSteamFurnace(event.created_entity)
	addGreenhouse(event.created_entity)
	addBorehole(event.created_entity)
	addBoreholeMaker(event.created_entity)
	--]]
	
	local func = tracker["add"][event.created_entity.name]
	if func then
		func(event.created_entity)
	end
end

local function onEntityRemoved(event)
	fluidSpill(event.entity)
	checkPollutionBlock(event.entity)
	doSpawnerDestructionSpawns(event.entity)
	
	--convertWasteWellToDepletedOil(event.entity)
	
	--[[
	removePollutionDetector(event.entity)
	removeGasBoiler(event.entity)
	removeSteamFurnace(event.entity)
	removeBorehole(event.entity)
	removeBoreholeMaker(event.entity)
	--]]
	
	local func = tracker["remove"][event.entity.name]
	if func then
		func(event.entity)
	end
end

local function onGameTick(event)
	initGlobal(false)
	
	if not global.nvday.loadTick then		
		for chunk in game.surfaces["nauvis"].get_chunks() do
			table.insert(global.nvday.chunk_cache, chunk)
		end
		for name,func in pairs(tracker["add"]) do
			local entities = game.surfaces["nauvis"].find_entities_filtered({name=name})
			for _,entity in pairs(entities) do
				func(entity)
			end
		end
		global.nvday.loadTick = true
	end
	
	local tick = game.tick
	doWaterPollution(tick)
	if tick%3600 == 0 then --check once every 60 seconds
		setPollutionAndEvoSettings()
	end
	ensureNoEarlyAttacks(tick)
	
	for name,func in pairs(tracker["tick"]) do
		func(tick)
	end
	--[[
	tickDetectors(tick)
	tickGasBoilers(tick)
	tickSteamFurnaces(tick)
	tickBoreholes(tick)
	tickBoreholeMakers(tick)
	--]]
	
	if tick%60 == 0 then
		local evo = game.forces.enemy.evolution_factor
		game.map_settings.unit_group.max_unit_group_size = getMaxEnemyWaveSize(evo) --200 is vanilla
	end
	if game.forces.enemy.evolution_factor < 0 then
		game.forces.enemy.evolution_factor = 0
	end
end

script.on_event(defines.events.on_entity_died, onEntityRemoved)
script.on_event(defines.events.on_preplayer_mined_item, onEntityRemoved)
script.on_event(defines.events.on_robot_pre_mined, onEntityRemoved)

script.on_event(defines.events.on_built_entity, onEntityAdded)
script.on_event(defines.events.on_robot_built_entity, onEntityAdded)

--[[
script.on_event(defines.events.on_built_tile, onTilesBuilt)
script.on_event(defines.events.on_robot_built_tile, onTilesBuilt)
--]]

script.on_event(defines.events.on_player_rotated_entity, onEntityRotated)

script.on_event(defines.events.on_resource_depleted, function(event)
	if Config.depleteWells and event.entity.prototype.resource_category == "basic-fluid" then
		event.entity.surface.create_entity{name="pollution-well", position=event.entity.position, amount=1}
		event.entity.destroy()
		return
	end
	if event.entity.prototype.resource_category == "borehole" then
		event.entity.surface.create_entity{name="filled-borehole", position=event.entity.position, amount=1, force = event.entity.force}
		event.entity.destroy()
		return
	end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
	initGlobal(false)
	if Config.depleteWells then
		return
	end
	
	table.insert(global.nvday.chunk_cache, chunk)
	
	local rand = game.create_random_generator()
	local x = (event.area.left_top.x+event.area.right_bottom.x)/2
	local y = (event.area.left_top.y+event.area.right_bottom.y)/2
	local seed = createSeed(event.surface, x+4, y+4)
	rand.re_seed(seed)
	local f0 = 1/160 --was 512, then 256, then 192
	local f1 = rand(0, 2147483647)/2147483647
	--game.print("Chunk at " .. x .. ", " .. y .. " with chance " .. f0 .. " / " .. f1)
	if f1 < f0 then
		--game.print("Genning Chunk at " .. x .. ", " .. y)
		x = x-16+rand(0, 32)
		y = y-16+rand(0, 32)
		generateEmptyWells(event.surface, event.area, x, y, rand)
	end
end)

script.on_event(defines.events.on_tick, onGameTick)