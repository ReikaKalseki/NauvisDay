require "__DragonIndustries__.tiles"

function spawnNuker(surface, source, target)
	local pos = {x = math.random(source.position.x-12, source.position.x+12), y = math.random(source.position.y-12, source.position.y+12)}
	--local evo = game.forces.enemy.evolution_factor
	--local size = math.floor(1 + evo*4)
	--for i = 1,size do
		local spawn = surface.create_entity({name = "wall-nuker", position = {math.random(pos.x-4, pos.x+4), math.random(pos.y-4, pos.y+4)}, force = game.forces.enemy})
		spawn.set_command({type = defines.command.attack, target = target, distraction = defines.distraction.none})
		rendering.draw_light{sprite="utility/light_medium", scale=0.7, intensity=1, color={r = 1, g = 0.75, b = 0.2}, target=spawn, surface=surface}
	--end
end

local function getBox(entity)
	local base = game.entity_prototypes[entity.name].collision_box
	base.left_top.x = base.left_top.x+entity.position.x
	base.right_bottom.x = base.right_bottom.x+entity.position.x
	base.left_top.y = base.left_top.y+entity.position.y
	base.right_bottom.y = base.right_bottom.y+entity.position.y
end

--need a tile that counts as water for building but does not look like water, but is fillable like water
local function createNukerCrater(nvday, nuker, radius)
	local x = math.floor(nuker.position.x)
	local y = math.floor(nuker.position.y)
	local tiles = {}
	local eggs = math.max(1, math.min(4, math.ceil(radius*radius/4)))
	for dx = -radius,radius do
		for dy = -radius,radius do
			local d = math.sqrt(dx*dx+dy*dy)
			if d <= radius+0.5 then
				local pos = {x = x+dx, y = y+dy}
				local at = nuker.surface.get_tile(pos.x, pos.y)
				if at and at.valid and string.find(at.name, "water", 1, true) then
				
				else
					local box = {{pos.x+0.05, pos.y+0.05}, {pos.x+0.95, pos.y+0.95}}
					local try = nuker.surface.find_entities_filtered{area = box, type = {"player", "entity-ghost", "corpse", "explosion", "particle", "trivial-smoke", "unit", "optimized-decorative"}, invert = true, limit = 1}
					if try and #try > 0 then
						--do nothing; will destroy an entity
					else
						table.insert(tiles, {name="nuker-goo", position=pos})
						try = nuker.surface.find_entities_filtered{area = box, type = "entity-ghost"}
						for _,ghost in pairs(try) do
							ghost.destroy()
						end
					end
				end
			end
		end
	end
	--game.print("Tried to spawn " .. eggs .. " eggs in " .. #tiles .. " tiles")
	local placed = 0
	if #tiles > 0 then
		nuker.surface.set_tiles(tiles)
		local tries = 0
		while placed < eggs and tries < 100 do
			local e = tiles[math.random(1, #tiles)]
			tries = tries+1
			if nuker.surface.can_place_entity ({name="soft-resin-egg", position=e.position, force=nuker.force, build_check_type=defines.build_check_type.blueprint_ghost, forced=true}) then--not isWaterEdge(nuker.surface, e.position.x, e.position.y) then
				local egg = nuker.surface.create_entity({name="soft-resin-egg", position=e.position, force=nuker.force})
				table.insert(nvday.worm_eggs, {entity=egg, laid=game.tick})
				placed = placed+1
			end
		end
	end
	--game.print("Successfully placed " .. placed)
end

function hatchWormEgg(entry, evo)
	if not (entry.entity and entry.entity.valid) then return end
	local type = "small-worm-turret"
	if evo > 0.75 and math.random() < 0.33 then
		type = "medium-worm-turret"
	end
	if evo > 0.9 and math.random() < 0.2 then
		type = "big-worm-turret"
	end
	entry.entity.surface.create_entity({name=type, position=entry.entity.position, force=entry.entity.force})
	entry.entity.destroy()
end

function onWallNukerDeath(event)
	local nuker = event.entity
	local killed = (event.cause and event.cause.type == "player") or (event.force and event.force == game.forces.player)
	local pos = nuker.position
	local r = 3;
	nuker.surface.create_entity({name="wall-nuker-explosion", position=nuker.position, force=nuker.force})
	local near = nuker.surface.find_entities_filtered{area = {{pos.x-r, pos.y-r}, {pos.x+r, pos.y+r}}, force = game.forces.player}
	for _,entity in pairs(near) do
		local damage = 0
		if entity.type == "wall" then
			entity.surface.create_entity({name="wall-explosion", position=entity.position, force=entity.force})
			entity.die()
		elseif entity.type == "player" then
			damage = 200 --with no armor, puts you at 20% health, 50% with heavy armor
		elseif entity.type == "ammo-turret" or entity.type == "fluid-turret" or entity.type == "electric-turret" or entity.type == "artillery-turret" or entity.type == "turret" then
			damage = math.min(game.entity_prototypes[entity.name].max_health/4, 50)
		else
			damage = math.min(game.entity_prototypes[entity.name].max_health/10, 20)
		end
		if damage > 0 then
			entity.damage(damage, nuker.force, "acid")
		end
	end
	for _,player in pairs(game.forces.player.players) do
		player.add_custom_alert(nuker, {type = "virtual", name = "nuker-alert"}, {"virtual-signal-name.nuker-alert", serpent.block(pos)}, true)
	end
	
	if killed and math.random() < 1-game.forces.enemy.evolution_factor*0.5 then
		--skip
	else
		createNukerCrater(global.nvday, nuker, killed and math.random(1, 3) or math.random(2, 5))
	end
end

local function getNukerChance()
	if game.forces.enemy.evolution_factor < WALL_NUKER_MINIMUM_EVO then
		return 0
	end
	local f = (game.forces.enemy.evolution_factor-WALL_NUKER_MINIMUM_EVO)/(1-WALL_NUKER_MINIMUM_EVO)
	return math.min(1, math.max(0.2, f*1.5-0.25))
end

local function getNukerSpawnSearchArea()
	local f = (game.forces.enemy.evolution_factor-WALL_NUKER_MINIMUM_EVO)/(1-WALL_NUKER_MINIMUM_EVO)
	return 12+f*f*48;
end

function trySpawnNuker(surface, x, y, s)
	if #game.players > 0 and math.random() < getNukerChance() then
		local pos = {x = x+s/2, y = y+s/2}
		local pollution = surface.get_pollution(pos)
		if pollution > Config.wallNukerThresh then
			local r = getNukerSpawnSearchArea()
			local box = {{pos.x-r, pos.y-r}, {pos.x+r, pos.y+r}}
			local spawners = surface.find_entities_filtered{type = "unit-spawner", force = game.forces.enemy, area = box}
			if spawners and #spawners > 0 then
				local spawner = spawners[math.random(1, #spawners)]
				--game.print("Found a spawner to spawn a tunnel nuker from.")
				local player = game.players[math.random(1, #game.players)]
				local pos2 = {x = player.position.x, y = player.position.y}
				pos2.x = pos2.x+math.random(-128, 128)
				pos2.y = pos2.y+math.random(-128, 128)
				r = 32
				box = {{pos2.x-r, pos2.y-r}, {pos2.x+r, pos2.y+r}}
				local targets = surface.find_entities_filtered{type = "wall", force = player.force, area = box}
				if targets and #targets > 0 then
					local target = targets[math.random(1, #targets)]
					spawnNuker(surface, spawner, target)
					--game.print("Found a target for a tunnel nuker.")
				end
			end
		end
	end
end