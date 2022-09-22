require "functions"
require "constants"
require "config"

require "wellgen"
require "pollutiondetection"
require "pollutionfx"
require "fans"
require "spills"
require "wallnukerai"

require "tracker-hooks"
require "caches"

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
	if nvday.boreholes == nil then
		nvday.boreholes = {}
	end
	if nvday.borers == nil then
		nvday.borers = {}
	end
	if nvday.spills == nil then
		nvday.spills = {}
	end
	if nvday.deaeros == nil then
		nvday.deaeros = {}
	end
	if nvday.deaeros.indices == nil then
		nvday.deaeros.indices = {}
	end
	if nvday.deaeros.cache == nil then
		nvday.deaeros.cache = {}
	end
	nvday.dirty = markDirty
end

script.on_configuration_changed(function()
	initGlobal(true)
	--setupTrackers()
	setPollutionAndEvoSettings(global.nvday)
	
	local names = {}
	for i = 1,4 do
		table.insert(names, "air-filter-machine-" .. i)
	end
	local nvday = global.nvday
	local n = 0
	for _,entity in pairs(game.surfaces.nauvis.find_entities_filtered{name = names}) do
		addDeaerosolizer(nvday, entity)
		n = n+1
		--entity.force.print("NauvisDay: Recaching Deaero #" .. entity.unit_number .. " @ " .. serpent.block(entity.position))
	end
	local c = 0
	for chunk in game.surfaces.nauvis.get_chunks() do
		for x = chunk.x*32,chunk.x*32+31 do
			for y = chunk.y*32,chunk.y*32+31 do
				local tile = game.surfaces.nauvis.get_tile(x, y)
				if tile.valid and stringStartsWith(tile.name, "polluted-") then
					local pos = {x, y}
					local hid = game.surfaces.nauvis.get_hidden_tile(pos)
					if (hid and hid.valid) then
						
					else
						game.surfaces.nauvis.set_hidden_tile(pos, game.tile_prototypes["water"])
						c = c+1
					end
				end
			end
		end
	end
	game.print("NauvisDay: Recached " .. n .. " deaerosolizers and repaired " .. c .. " sludge tiles in cache.")
end)

script.on_init(function()
	initGlobal(true)
	--setupTrackers()
	setPollutionAndEvoSettings(global.nvday)
end)

script.on_load(function()
	--setupTrackers()
end)

script.on_event(defines.events.on_console_command, function(event)
	setPollutionAndEvoSettings(global.nvday)
end)

local function onEntityRotated(event)
	local nvday = global.nvday
	
	rotatePollutionFan(nvday, event.entity)
end

local function onTileMined(event)
	local amt = 0
	local miner = event.player_index and game.players[event.player_index].character or event.robot
	if miner then
		for _,pair in ipairs(event.tiles) do
			if stringStartsWith(pair.old_tile.name, "polluted-") then
				amt = amt+1
			end
		end
		if amt > 0 then
			game.surfaces[event.surface_index].pollute(miner.position, Config.pollutedWaterTileCleanup*Config.pollutedWaterTileRelease*2)
			miner.damage(miner.prototype.max_health*0.05, miner.force, "poison")
		end
	end
end

local function onEntityAdded(event)
	local nvday = global.nvday
	
	local entity = event.created_entity
	
	if entity.name == "storage-machine" and entity.force.technologies["pollution-storage-2"].researched then
		entity = upgradeStorageMachine(entity)
	end
	
	trackEntityAddition(entity, nvday)
	
	if string.find(entity.name, "air-filter-machine-", 1, 1) then
		if entity.type == "assembling-machine" then --check type since AirFilter mod is otherwise going to be caught here
			entity.set_recipe("air-cleaning-action")
			game.print("Initializing Deaero.")
			--entity.operable = false
		else
			if event.player_index then
				game.players[event.player_index].print("There is no point in using this with NauvisDay installed. Use its deaerosolizers instead.")
			elseif entity.force then
				entity.force.print("There is no point in using this with NauvisDay installed. Use its deaerosolizers instead.")
			end
		end
	end
	
	if entity.name == "venting-machine" then
		entity.set_recipe("pollution-venting-action")
		--entity.operable = false
	end
end

local function onEntityRemoved(event)
	local nvday = global.nvday
	
	trackEntityRemoval(event.entity, nvday)
	
	fluidSpill(event.entity)
	checkPollutionBlock(event.entity)
	doSpawnerDestructionSpawns(event.entity)
	doTreeFarmTreeDeath(event.entity)
end

local function onEntityDied(event)
	if event.entity.name == "wall-nuker" then
		onWallNukerDeath(event)
	end
	onEntityRemoved(event)
end

local function onEntityDamaged(event)
	local target = event.entity
	local source = event.cause
	local type = event.damage_type
	local amount = event.final_damage_amount
	if source and source.name == "wall-nuker" and target.type ~= "player" then
		source.damage(game.entity_prototypes[source.name].max_health/10, source.force, type.name)
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
		
		if game.active_mods["air-filtering"] then
			game.print("NauvisDay: Detected AirFilters mod; NauvisDay contains all the features it does and far more, making AirFilters somewhat useless to have installed together with it.")
		end
	end
	
	runTickHooks(nvday, event.tick)
	
	local tick = event.tick
	doAmbientPollutionEffects(nvday, tick)
	if tick%3600 == 0 then --check once every 60 seconds
		setPollutionAndEvoSettings(nvday)
	end
	ensureNoEarlyAttacks(tick)
	
	if tick%15 == 0 then
		for _,player in pairs(game.players) do
			if player.selected == nil then
				setSpillGui(player, nil)
			end
		end
		tickSpilledFluids(nvday, tick%60 == 0)
	end
	
	if tick%60 == 0 then
		local evo = game.forces.enemy.evolution_factor
		local cap = getInterpolatedValue(maxAttackSizeCurveLookup, evo)
		cap = math.max(10, math.ceil(cap*Config.attackSize))
		if not cap then game.print("ERROR: NULL INTERPOLATE FROM " .. serpent.block(evo) .. " into " .. serpent.block(maxAttackSizeCurveLookup.values)) end
		game.map_settings.unit_group.max_unit_group_size = math.ceil(cap) --200 is vanilla
	end
	if game.forces.enemy.evolution_factor < 0 then
		game.forces.enemy.evolution_factor = 0
	end
end

script.on_event(defines.events.on_selected_entity_changed, handleFluidSpillTooltip)

script.on_event(defines.events.on_entity_died, onEntityDied)
script.on_event(defines.events.on_pre_player_mined_item, onEntityRemoved)
script.on_event(defines.events.on_robot_pre_mined, onEntityRemoved)
script.on_event(defines.events.script_raised_destroy, onEntityRemoved)

script.on_event(defines.events.on_built_entity, onEntityAdded)
script.on_event(defines.events.on_robot_built_entity, onEntityAdded)

script.on_event(defines.events.on_player_mined_tile, onTileMined)
script.on_event(defines.events.on_robot_mined_tile, onTileMined)

script.on_event(defines.events.on_player_rotated_entity, onEntityRotated)

script.on_event(defines.events.on_entity_damaged, onEntityDamaged)

script.on_event(defines.events.on_player_flushed_fluid, function(event)
	--if event.fluid == "waste" then
		spillFluidsAt(event.fluid, event.amount, event.entity)
	--end
end)

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

local function onFinishedResearch(event)
	local tech = event.research
	local force = event.research.force
	local nvday = global.nvday
	if tech.name == "pollution-storage-2" then
		for _,e in pairs(game.surfaces.nauvis.find_entities_filtered{name = "storage-machine", force = force}) do
			local repl = upgradeStorageMachine(e)
		end
	end
end

script.on_event(defines.events.on_tick, onGameTick)

script.on_event(defines.events.on_research_finished, onFinishedResearch)