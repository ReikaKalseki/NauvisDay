require "functions"
require "constants"
require "config"

require "wellgen"
require "pollutiondetection"
require "pollutionfx"
require "fans"

require "entitytracker"

function initGlobal(markDirty)
	if not global.nvday then
		global.nvday = {}
	end
	local nvday = global.nvday
	if nvday.chunk_cache == nil then
		nvday.chunk_cache = {}
	end
	if nvday.pollution_detectors == nil then
		nvday.pollution_detectors = {}
	end
	if nvday.pollution_fans == nil then
		nvday.pollution_fans = {}
	end
	if nvday.gas_boilers == nil then
		nvday.gas_boilers = {}
	end
	if nvday.steam_furnaces == nil then
		nvday.steam_furnaces = {}
	end
	if nvday.boreholes == nil then
		nvday.boreholes = {}
	end
	if nvday.borers == nil then
		nvday.borers = {}
	end
	if nvday.spills == nil then
		nvday.spills = {}
	end
	nvday.dirty = markDirty
end

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

local function onEntityRotated(event)
	local nvday = global.nvday
	
	rotateGasBoiler(nvday, event.entity)
	rotatePollutionFan(nvday, event.entity)
end

local function onEntityAdded(event)
	local nvday = global.nvday
	
	local func = tracker["add"][event.created_entity.name]
	if func then
		func(nvday, event.created_entity)
	end
end

local function onEntityRemoved(event)
	local nvday = global.nvday
	
	fluidSpill(event.entity)
	checkPollutionBlock(event.entity)
	doSpawnerDestructionSpawns(event.entity)
	doTreeFarmTreeDeath(event.entity)
	
	local func = tracker["remove"][event.entity.name]
	if func then
		func(nvday, event.entity)
	end
end

local function onGameTick(event)
	local nvday = global.nvday
	
	if nvday.dirty then		
		nvday.chunk_cache = {}
		for chunk in game.surfaces["nauvis"].get_chunks() do
			table.insert(nvday.chunk_cache, chunk)
		end
		--[[
		for name,func in pairs(tracker["add"]) do
			local entities = game.surfaces["nauvis"].find_entities_filtered({name=name})
			for _,entity in pairs(entities) do
				func(entity)
			end
		end
		--]]
		nvday.dirty = false
	end
	
	local tick = event.tick
	doAmbientPollutionEffects(nvday, tick)
	if tick%3600 == 0 then --check once every 60 seconds
		setPollutionAndEvoSettings()
	end
	ensureNoEarlyAttacks(tick)
	
	if tick%15 == 0 then
		tickSpilledFluids(nvday, tick%60 == 0)
	end
	
	for name,func in pairs(tracker["tick"]) do
		func(nvday, tick)
	end
	
	if tick%60 == 0 then
		local evo = game.forces.enemy.evolution_factor
		game.map_settings.unit_group.max_unit_group_size = getMaxEnemyWaveSize(evo) --200 is vanilla
	end
	if game.forces.enemy.evolution_factor < 0 then
		game.forces.enemy.evolution_factor = 0
	end
end

script.on_event(defines.events.on_selected_entity_changed, handleFluidSpillTooltip)

script.on_event(defines.events.on_entity_died, onEntityRemoved)
script.on_event(defines.events.on_pre_player_mined_item, onEntityRemoved)
script.on_event(defines.events.on_robot_pre_mined, onEntityRemoved)

script.on_event(defines.events.on_built_entity, onEntityAdded)
script.on_event(defines.events.on_robot_built_entity, onEntityAdded)

script.on_event(defines.events.on_player_rotated_entity, onEntityRotated)

script.on_event(defines.events.on_resource_depleted, function(event)
	if Config.depleteWells and event.entity.prototype.resource_category == "basic-fluid" then
		if not (event.entity.prototype == "crude-oil" and game.active_mods["Fracking"]) then
			event.entity.surface.create_entity{name="pollution-well", position=event.entity.position, amount=1}
			event.entity.destroy()
		end
		return
	end
	if event.entity.prototype.resource_category == "borehole" then
		event.entity.surface.create_entity{name="filled-borehole", position=event.entity.position, amount=1, force = event.entity.force}
		event.entity.destroy()
		return
	end
end)

script.on_event(defines.events.on_chunk_generated, function(event)	
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