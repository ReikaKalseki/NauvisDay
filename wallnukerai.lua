local function spawnNuker(spawner, target)
	local pos = {math.random(spawner.position.x-12, spawner.position.x+12), math.random(spawner.position.y-12, spawner.position.y+12)}
	local group = surface.create_unit_group({position={pos.x+16, pos.y+16}, force=game.forces.enemy})
	local evo = game.forces.enemy.evolution_factor
	local size = math.floor(1 + evo*4)
	while #retaliation.members < size do
		local spawn = surface.create_entity({name = "wall-nuker", position = {math.random(pos.x-4, pos.x+4), math.random(pos.y-4, pos.y+4)}, force = game.forces.enemy})
		retaliation.add_member(spawn)
	end
	retaliation.set_command({type = defines.command.attack, target = target, distraction = defines.distraction.none})
end

local spawnernum = 19106999
local turretnum = 20259969

local function findNukableTarget()
	--game.forces.enemy.find_
end

function onWallNukerDeath(nuker)
	local pos = nuker.position
	local r = 3;
	nuker.surface.create_entity({name="wall-nuker-explosion", position=nuker.position, force=nuker.force})
	local near = nuker.surface.find_entities_filtered{area = {{pos.x-r, pos.y-r}, {pos.x+r, pos.y+r}}, force = game.forces.player}
	for _,entity in pairs(near) do
		local damage = 0;
		if entity.type == "wall" then
			entity.surface.create_entity({name="wall-explosion", position=entity.position, force=entity.force})
			entity.die()
		elseif entity.type == "player" then
			damage = 200 --with no armor, puts you at 20% health, 50% with heavy armor
		elseif entity.type == "ammo-turret" or entity.type == "tluid-turret" or entity.type == "electric-turret" or entity.type == "turret"
			damage = math.min(game.entity_prototypes[entity.name].max_health/4, 50)
		else
			damage = math.min(game.entity_prototypes[entity.name].max_health/10, 20)
		end
		entity.damage(damage, nuker.force, "acid")
	end
	
	--maybe sometimes make a small crater that needs filling to be able to be built on
end