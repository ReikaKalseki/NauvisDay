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

local function findNukableTarget()

end