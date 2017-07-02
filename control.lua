require "functions"
require "constants"
require "config"

local ranTick = false

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
	local tick = game.tick
	if not ranTick then
		onFirstTick(tick)
		ranTick = true
	end
	--doWaterPollution(tick) TOO LAGGY
	ensureNoEarlyAttacks(tick)
	if game.forces.enemy.evolution_factor < 0 then
		game.forces.enemy.evolution_factor = 0
	end
	
	--[[
	local src = "dirt-dark"
	local tgt = "grass-purple-fade"
	for x = -1,1 do
		for y = -1,1 do
			local dx = game.players[1].position.x+x
			local dy = game.players[1].position.y+y
			local tile = game.players[1].surface.get_tile(dx, dy).name
			if tile == src then
				game.players[1].surface.set_tiles({{name=tgt, position={dx, dy}}})
				game.print("Replaced tile @ " .. dx .. ", " .. dy)
			end
		end
	end
	--]]
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