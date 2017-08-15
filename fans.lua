require "constants"
require "functions"

function addFan(entity)
	if entity.name == "pollution-fan" then
		addFanToTable(entity)
	end
end

function removeFan(entity)
	if entity.name == "pollution-fan" then
		for i, pollution_fan in ipairs(global.nvday.pollution_fans) do
			if pollution_fan.position.x == entity.position.x and pollution_fan.position.y == entity.position.y then
				table.remove(global.nvday.pollution_fans, i)
				break
			end
		end
	end
end

function tickFans(tick)
	if tick%fanTickRate == 0 then
		for _,fan in ipairs(global.nvday.pollution_fans) do
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
		end
	end
end

function addFanToTable(entity)
	entity.operable = false
	table.insert(global.nvday.pollution_fans, entity)
end