local function spawnNuker(surface, spawner, target)
	local pos = {x = math.random(spawner.position.x-12, spawner.position.x+12), y = math.random(spawner.position.y-12, spawner.position.y+12)}
	local group = surface.create_unit_group({position={pos.x+16, pos.y+16}, force=game.forces.enemy})
	local evo = game.forces.enemy.evolution_factor
	local size = math.floor(1 + evo*4)
	while #group.members < size do
		local spawn = surface.create_entity({name = "wall-nuker", position = {math.random(pos.x-4, pos.x+4), math.random(pos.y-4, pos.y+4)}, force = game.forces.enemy})
		group.add_member(spawn)
	end
	group.set_command({type = defines.command.attack, target = target, distraction = defines.distraction.none})
end

function onWallNukerDeath(nuker)
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
	
	--maybe sometimes make a small crater that needs filling to be able to be built on
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