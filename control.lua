require "functions"
require "constants"
require "config"

require "wellgen"

local ranTick = false

script.on_init(function()
	setPollutionAndEvoSettings()
end)

script.on_configuration_changed(function()
	setPollutionAndEvoSettings()
end)

script.on_event(defines.events.on_console_command, function(event)
	setPollutionAndEvoSettings()
end)

local function onEntityAdded(event)
	--convertDepletedOilToWasteWell(event.created_entity)
end

local function onEntityRemoved(event)
	fluidSpill(event.entity)
	checkPollutionBlock(event.entity)
	doSpawnerDestructionSpawns(event.entity)
	--convertWasteWellToDepletedOil(event.entity)
end

local function onGameTick(event)
	--doWaterPollution(tick) TOO LAGGY
	local tick = game.tick
	if tick%3600 == 0 then --check once every 60 seconds
		setPollutionAndEvoSettings()
	end
	ensureNoEarlyAttacks(tick)
	if game.forces.enemy.evolution_factor < 0 then
		game.forces.enemy.evolution_factor = 0
	end
end

script.on_event(defines.events.on_entity_died, onEntityRemoved)
script.on_event(defines.events.on_preplayer_mined_item, onEntityRemoved)
script.on_event(defines.events.on_robot_pre_mined, onEntityRemoved)

script.on_event(defines.events.on_built_entity, onEntityAdded)
script.on_event(defines.events.on_robot_built_entity, onEntityAdded)

script.on_event(defines.events.on_resource_depleted, function(event)
	if Config.depleteWells and event.entity.prototype.resource_category == "basic-fluid" then
		event.entity.surface.create_entity{name="pollution-well", position=event.entity.position, amount=1}
		event.entity.destroy()
	end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
	if Config.depleteWells then
		return
	end
	
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