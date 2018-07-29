local function spawnNuker(surface, spawner, target)
	local pos = {x = math.random(spawner.position.x-12, spawner.position.x+12), y = math.random(spawner.position.y-12, spawner.position.y+12)}
	--local evo = game.forces.enemy.evolution_factor
	--local size = math.floor(1 + evo*4)
	--for i = 1,size do
		local spawn = surface.create_entity({name = "wall-nuker", position = {math.random(pos.x-4, pos.x+4), math.random(pos.y-4, pos.y+4)}, force = game.forces.enemy})
		spawn.set_command({type = defines.command.attack, target = target, distraction = defines.distraction.none})
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
local function createNukerCrater(nuker, radius)
	local x = math.floor(nuker.position.x)
	local y = math.floor(nuker.position.y)
	local tiles = {}
	for dx = -radius,radius do
		for dy = -radius,radius do
			local d = math.sqrt(dx*dx+dy*dy)
			if d <= radius+0.5 then
				local pos = {x = x+dx, y = y+dy}
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
	if #tiles > 0 then
		nuker.surface.set_tiles(tiles)
	end
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
		elseif entity.type == "ammo-turret" or entity.type == "tluid-turret" or entity.type == "electric-turret" or entity.type == "turret" then
			damage = math.min(game.entity_prototypes[entity.name].max_health/4, 50)
		else
			damage = math.min(game.entity_prototypes[entity.name].max_health/10, 20)
		end
		if damage > 0 then
			entity.damage(damage, nuker.force, "acid")
		end
	end
	
	if killed or math.random() < 0.25 then
		createNukerCrater(nuker, killed and math.random(2, 5) or math.random(1, 3))
	end
end

local function getNukerChance()
	local thresh = 0.4
	if game.forces.enemy.evolution_factor < thresh then
		return 0
	end
	local f = (game.forces.enemy.evolution_factor-thresh)/(1-thresh)
	return math.min(1, math.max(0.2, f*1.5-0.25))
end

function trySpawnNuker(surface, x, y, s)
	if #game.players > 0 and math.random() < getNukerChance() then
		local pos = {x = x+s/2, y = y+s/2}
		local pollution = surface.get_pollution(pos)
		if pollution > Config.wallNukerThresh then
			local r = 12
			local box = {{pos.x-r, pos.y-r}, {pos.x+r, pos.y+r}}
			local spawners = surface.find_entities_filtered{type = "unit-spawner", force = game.forces.enemy, area = box}
			if spawners and #spawners > 0 then
				local spawner = spawners[math.random(1, #spawners)]
				--game.print("Found a spawner to spawn a tunnel nuker from.")
				local player = game.players[math.random(1, #game.players)]
				local pos2 = {x = player.position.x, y = player.position.y}
				pos2.x = pos2.x+math.random(-128, 128)
				pos2.y = pos2.y+math.random(-128, 128)
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