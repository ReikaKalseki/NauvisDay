require "constants"
require "functions"

function addFan(nvday, entity)
	if entity.name == "pollution-fan" then
		addFanToTable(nvday, entity)
	end
end

function removeFan(nvday, entity)
	if entity.name == "pollution-fan" then
		for i, entry in ipairs(nvday.pollution_fans) do
			if entry.fan.position.x == entity.position.x and entry.fan.position.y == entity.position.y then
				entry.input.destroy()
				entry.output.destroy()
				table.remove(nvday.pollution_fans, i)
				break
			end
		end
	end
end

function tickFans(nvday, tick)
	if tick%fanTickRate == 0 then
		for i,entry in ipairs(nvday.pollution_fans) do
			local fan = entry.fan
			if fan.valid then
				if fan.energy > 0 then
					fan.active = true
					local control = fan.get_control_behavior()
					if not (control and control.disabled) then
						entry.input.fluidbox[1] = {name=(game.fluid_prototypes["air"] and "air" or (game.fluid_prototypes["compressed-air"] and "compressed-air" or (game.fluid_prototypes["liquid-air"] and "liquid-air" or "steam"))), amount = 1000}
						entry.output.fluidbox[1] = nil
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
						if tick%30 == 0 then
							surface.create_entity({name="fan-sound", position=fan.position})
						end
					end
				else
					fan.active = false
				end
			else
				table.remove(nvday.pollution_fans, i)
			end
		end
	end
end

local function getPollutionFanEntry(nvday, entity)
	if entity.name == "pollution-fan" then
		for i, entry in ipairs(nvday.pollution_fans) do
			if entry.fan.position.x == entity.position.x and entry.fan.position.y == entity.position.y then
				return entry
			end
		end
	end
	if entity.name == "pollution-fan-tank" then
		for i, entry in ipairs(nvday.pollution_fans) do
			if entry.input.position.x == entity.position.x and entry.input.position.y == entity.position.y then
				return entry
			end
			if entry.output.position.x == entity.position.x and entry.output.position.y == entity.position.y then
				return entry
			end
		end
	end
	return nil
end

function rotatePollutionFan(nvday, entity)
  if entity.name == "pollution-fan" then
	local entry = getPollutionFanEntry(nvday, entity)
	local dx = 0
	local dy = 0
	if entity.direction == defines.direction.north then
		dy = -2
	end
	if entity.direction == defines.direction.south then
		dy = 2
	end
	if entity.direction == defines.direction.east then
		dx = 2
	end
	if entity.direction == defines.direction.west then
		dx = -2
	end
	entry.input.destroy()
	entry.output.destroy()
	local inp = entity.surface.create_entity({name="pollution-fan-tank", position={entity.position.x-dx, entity.position.y-dy}, force=entity.force, direction = entity.direction})
	local outp = entity.surface.create_entity({name="pollution-fan-tank", position={entity.position.x+dx, entity.position.y+dy}, force=entity.force, direction = getOppositeDirection(entity.direction)})
	entry.input = inp
	entry.output = outp
  end
end

function addFanToTable(nvday, entity)
	--entity.operable = false
	local dx = 0
	local dy = 0
	if entity.direction == defines.direction.north then
		dy = -2
	end
	if entity.direction == defines.direction.south then
		dy = 2
	end
	if entity.direction == defines.direction.east then
		dx = 2
	end
	if entity.direction == defines.direction.west then
		dx = -2
	end
	local inp = entity.surface.create_entity({name="pollution-fan-tank", position={entity.position.x-dx, entity.position.y-dy}, force=entity.force, direction = entity.direction})
	local outp = entity.surface.create_entity({name="pollution-fan-tank", position={entity.position.x+dx, entity.position.y+dy}, force=entity.force, direction = getOppositeDirection(entity.direction)})
	table.insert(nvday.pollution_fans, {fan=entity, input = inp, output = outp})
end