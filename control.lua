require "functions"
require "constants"
require "config"

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
	if event.entity.prototype.resource_category == "basic-fluid" then
		event.entity.surface.create_entity{name="pollution-well", position=event.entity.position, amount=1}
		event.entity.destroy()
	end
end)

script.on_event(defines.events.on_tick, onGameTick)