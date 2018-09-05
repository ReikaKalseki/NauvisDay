require "config"
require "constants"

function getSpillTooltip(entry)
	return entry.amount .. " units, +" .. entry.lastemit .. " pollution/s" -- entry.amount .. " units<br>-" .. entry.lastevap .. " units/s<br>+" .. entry.lastemit .. " pollution/s" --no way to do newlines
end

local function createSpillKey(position)
	return position.x .. "&" .. position.y
end

function setSpillGui(player, spill)
	for _,elem in pairs(player.gui.top.children) do
		if elem.name == "spillgui" then
			local entry = global.nvday.spills[elem.tooltip] --since tooltip == key
			if entry and entry.gui then
				entry.gui[player.name] = nil
			end
			elem.destroy()
			break
		end
	end
	
	if spill then
		local entry = getSpillEntryFor(spill)
		if not entry then
			game.print("No entry for spill " .. createSpillKey(spill.position))
			spill.destroy()
			return
		end
		local gui = player.gui.top.add{type = "frame", name = "spillgui", caption = getSpillTooltip(entry)}
		gui.tooltip = entry.key
		if not entry.gui then entry.gui = {} end
		entry.gui[player.name] = gui
	end
end

function isFluidSpill(entity)
	return entity.type == "simple-entity" and string.find(entity.name, "spilled", 1, true)
end

function handleFluidSpillTooltip(event)
	local player = game.players[event.player_index]
	local last = event.last_entity
	local current = player.selected
	if current and isFluidSpill(current) then
		setSpillGui(player, current)
	elseif last and isFluidSpill(last) then
		setSpillGui(player, nil)
	end
end

function getSpillEntryFor(entity)
	return global.nvday.spills[createSpillKey(entity.position)]
end

local function findNearSpill(fluid, source)
	local area = {{source.position.x-4, source.position.y-4}, {source.position.x+4, source.position.y+4}}
	for i = 5,1,-1 do 
		local name = "spilled-" .. fluid.name .. "-" .. i
		local li = source.surface.find_entities_filtered({type = "simple-entity", name = name, area = area})
		--game.print(#li .. " for " .. name)
		if #li > 0 and li[1].valid then
			return getSpillEntryFor(li[1])
		end
	end
	return nil
end

local function calculateSpillStage(amount)
	if amount < 60 then
		return 1
	elseif amount < 200 then
		return 2
	elseif amount < 1000 then
		return 3
	elseif amount < 10000 then
		return 4
	else
		return 5
	end
end

function setSpillStage(entry)
	local stage = calculateSpillStage(entry.amount)
	if entry.stage ~= stage then
		--game.print("Set stage from " .. entry.stage .. " to " .. stage)
		entry.stage = stage
		local pos = entry.entity.position
		local surf = entry.entity.surface
		entry.entity.destroy()
		local name = "spilled-" .. entry.fluid .. "-" .. stage
		entry.entity = surf.create_entity{name = name, position = pos, force = game.forces.neutral}
	end
end

local function createSpill(fluid, source)
	local near = findNearSpill(fluid, source)
	if near and near.entity.valid then
		--game.print("Added " .. fluid.amount .. " to " .. near.amount)
		near.amount = math.floor(near.amount+fluid.amount)
		setSpillStage(near)
		near.age = 0
	else
		local stage = calculateSpillStage(fluid.amount)
		local name = "spilled-" .. fluid.name .. "-" .. stage
		local entity = source.surface.create_entity{name = name, position = source.position, force = game.forces.neutral}
		entity.destructible = false
		local key = createSpillKey(source.position)
		local entry = {fluid = fluid.name, amount = math.floor(fluid.amount), entity = entity, age = 0, stage = stage, key = key, lastemit = 0, lastevap = 0}
		--game.print("spilling " .. fluid.amount .. " of " .. fluid.name .. " stage " .. stage)
		global.nvday.spills[key] = entry
		tickSpill(entry, global.nvday, false, true)
	end
end

function fluidSpill(e)
	if #e.fluidbox > 0 then
		for i = 1, #e.fluidbox do
			if e.fluidbox[i] and e.fluidbox[i].amount > 0 then
				createSpill(e.fluidbox[i], e)
			end
		end
	end
end

function tickSpill(entry, nvday, doText, simulate)
	local f = liquidPollutionFactors[entry.fluid]
	local f2 = liquidEvaporationFactors[entry.fluid]
	if not f then f = 1 end
	if not f2 then f2 = 1 end
	local amt = math.max(1, math.floor(f2*entry.amount/64))
	local pol = math.floor(amt*f+0.5)
	
	entry.lastemit = pol*4 --per-second pollution emission
	entry.lastevap = amt*4
	
	if not simulate then
		entry.entity.surface.pollute(entry.entity.position, pol)
		entry.amount = entry.amount-amt
		entry.age = entry.age+1
		
		--game.print("Evaporating " .. amt .. " of " .. entry.fluid .. " into " .. pol .. " pollution; " .. entry.amount .. " remaining")
		--[[if doText then
			entry.entity.surface.create_entity({name = "flying-text", position = entry.entity.position, force=game.forces.neutral, text = "Evaporating " .. amt .. " of " .. entry.fluid .. " into " .. pol .. " pollution; " .. entry.amount .. " remaining"})
		end--]]
		if entry.amount <= 0 then
			nvday.spills[entry.key] = nil
	
			for _,player in pairs(game.players) do
				if player.selected == entry.entity then
					setSpillGui(player, nil)
				end
			end
			
			entry.entity.destroy()
		else
			setSpillStage(entry)
			
			if doText and entry.gui then
				for _,elem in pairs(entry.gui) do
					elem.caption = getSpillTooltip(entry)
				end
			end
			if liquidDamageLevels[entry.fluid] then
				for _,player in pairs(game.players) do
					if player.character then -- MP players not currently logged in do not have chars
						if math.abs(player.character.position.x-entry.entity.position.x) <= 3 and math.abs(player.character.position.y-entry.entity.position.y) <= 3 then
							player.character.damage(liquidDamageLevels[entry.fluid], game.forces.neutral)
						end
					end
				end
			end
		end
	end
end

function tickSpilledFluids(nvday, doText)
	for _,entry in pairs(nvday.spills) do
		if entry.entity.valid then
			tickSpill(entry, nvday, doText, false)
		else
			nvday.spills[entry.key] = nil
		end
	end
end