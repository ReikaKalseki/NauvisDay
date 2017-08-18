require "constants"
require "functions"

function addFan(entity)
	if entity.name == "pollution-fan" then
		local ore = entity.surface.create_entity({name="fan-ore", position=entity.position, force=game.forces.neutral, amount=1000})
		addFanToTable(entity, entity.surface.create_entity({name="pollution-fan-placer", position=entity.position, force=entity.force, direction=entity.direction}), ore)
	end
	if entity.name == "pollution-fan-placer" then
		local ore = entity.surface.create_entity({name="fan-ore", position=entity.position, force=game.forces.neutral, amount=1000})
		addFanToTable(entity.surface.create_entity({name="pollution-fan", position=entity.position, force=entity.force, direction=entity.direction}), entity, ore)
	end
end

function removeFan(entity)
	if entity.name == "pollution-fan" then
		for i, entry in ipairs(global.nvday.pollution_fans) do
			if entry.fan.position.x == entity.position.x and entry.fan.position.y == entity.position.y then
				if entry.placer.valid then
					entry.placer.destroy()
				end
				entry.ore.destroy()
				table.remove(global.nvday.pollution_fans, i)
				break
			end
		end
	end
	if entity.name == "pollution-fan-placer" then
		for i, entry in ipairs(global.nvday.pollution_fans) do
			if entry.placer.position.x == entity.position.x and entry.placer.position.y == entity.position.y then
				if entry.fan.valid then
					entry.fan.destroy()
				end
				entry.ore.destroy()
				table.remove(global.nvday.pollution_fans, i)
				break
			end
		end
	end
end

function tickFans(tick)
	if tick%fanTickRate == 0 then
		for i,entry in ipairs(global.nvday.pollution_fans) do
			local fan = entry.fan
			if fan.valid then
				if fan.energy > 0 then
					local pos = fan.position
					local surface = fan.surface
					local pollution = surface.get_pollution(pos)
					local vec = directionToVector(fan.direction)
					local vecperp = directionToVector(getPerpendicularDirection(fan.direction))
					for i = 1,#fanPollutionSpread do
						for k = -1,1 do
							local pos2 = {pos.x+vec.dx*i*32+k*vecperp.dx*32, pos.y+vec.dy*i*32+k*vecperp.dy*32}
							local poll2 = surface.get_pollution(pos2)
							local move = fanPollutionSpread[i]*(pollution-poll2)*fanPollutionMoveFactor
							if k ~= 0 then
								move = move*fanPollutionLateralSpread[i]
							end
							if move > 0 then
								surface.pollute(pos, -move/2*fanTickRate/60)
								surface.pollute(pos2, move/2*fanTickRate/60)
							end
						end
					end
				end
			else
				entry.ore.destroy()
				table.remove(global.nvday.pollution_fans, i)
			end
		end
	end
end

function addFanToTable(entity, placer, ore)
	entity.operable = false
	placer.operable = false
	table.insert(global.nvday.pollution_fans, {fan=entity, placer=placer, ore=ore})
end