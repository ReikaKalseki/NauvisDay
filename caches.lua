require "config"
require "constants"

local function tickDeaero(entry)
	--game.print(entry.id)
	local pollution = entry.entity.surface.get_pollution(entry.entity.position)
	local eff = getInterpolatedValue(deaeroEfficiencyCurveLookup, pollution)
	--game.print("Deaero " .. entry.id .. " has " .. pollution .. " pollution, efficiency = " .. eff)
	if eff <= 0 then
		entry.entity.active = false
	else
		entry.entity.active = true
		local n = getDeaeroRecipeName(eff)
		--local recipe = entry.entity.force.recipes[n]
		local water = entry.entity.fluidbox[1]
		local sludge = entry.entity.fluidbox[2]
		local frac = entry.entity.crafting_progress
		entry.entity.set_recipe(n)
		entry.entity.fluidbox[1] = water
		entry.entity.fluidbox[2] = sludge
		entry.entity.crafting_progress = frac
	end
end

function tickDeaerosolizers(nvday, tick)
	if tick%deaeroTickRate == 0 then
		if not nvday.deaeros.modulo then nvday.deaeros.modulo = 0 end
		--game.print(tick .. " : " .. nvday.deaeros.modulo)
		if nvday.deaeros.indices[nvday.deaeros.modulo] then
			for unit,entry in pairs(nvday.deaeros.indices[nvday.deaeros.modulo]) do
				if entry.entity.valid then
					tickDeaero(entry)
				else
					nvday.deaeros.indices[nvday.deaeros.modulo][entry.id] = nil
					nvday.deaeros.cache[entry.id] = nil
				end
			end
		end
		nvday.deaeros.modulo = (nvday.deaeros.modulo+1)%deaeroTickSpread
	end
end

function addDeaerosolizer(nvday, entity)
	local entry = {entity = entity, age = game.tick, modulo = math.random(0, deaeroTickSpread-1), id = entity.unit_number}
	if not nvday.deaeros.indices[entry.modulo] then
		nvday.deaeros.indices[entry.modulo] = {}
	end
	nvday.deaeros.indices[entry.modulo][entry.id] = entry
	nvday.deaeros.cache[entry.id] = entry
	--game.print(entry.id)
end

function removeDeaerosolizer(nvday, entity)
	local entry = nvday.deaeros.cache[entity.unit_number]
	if entry then
		nvday.deaeros.indices[entry.modulo][entry.id] = nil
		nvday.deaeros.cache[entry.id] = nil
	end
end

local function hasIngredients(furnace)
	local inv = furnace.get_inventory(defines.inventory.furnace_source)
	local fluids = {}
	for i= 1,#furnace.fluidbox do
		local fluid = furnace.fluidbox[i]
		if fluid then
			fluids[fluid.name] = fluid.amount
		end
	end
	for _,ingredient in pairs(furnace.get_recipe().ingredients) do
		if ingredient.type == "item" then
			local has = inv.get_item_count(ingredient.name)
			if has < ingredient.amount then
				return false
			end
		end
		if ingredient.type == "fluid" and ingredient.name ~= "steam" then
			if (not fluids[ingredient.name]) or fluids[ingredient.name] < ingredient.amount then
				return false
			end
		end
	end
	return true
end

function tickSteamFurnaces(nvday, tick)
	if tick%60 == 0 then
		for _,furnace in pairs(nvday.steam_furnaces) do
			if furnace.get_recipe() and hasIngredients(furnace) then
				furnace.crafting_progress = math.max(furnace.crafting_progress, 0.005)
			end
			local fluid = furnace.fluidbox[#furnace.fluidbox]
			if fluid and fluid.name == "steam" and fluid.amount >= 5 then
				furnace.burner.currently_burning = game.item_prototypes["coal"]
				furnace.burner.remaining_burning_fuel = 50000000
			else
				furnace.burner.remaining_burning_fuel = 0
			end
		
			--entry.furnace.energy = 300
			
			--[[
			local furnaces = furnace.surface.find_entities_filtered({name = furnace.name, area = {{furnace.position.x-8, furnace.position.y-8}, {furnace.position.x+8, furnace.position.y+8}}})
			if #furnaces > 1 then
				local totalsteam = 0
				for _,furnace2 in pairs(furnaces) do
					if furnace2.fluidbox[1] then
						--game.print("Adding " .. furnace2.fluidbox[1].amount .. "steam")
						totalsteam = totalsteam+furnace2.fluidbox[1].amount
					end
				end
				local avgsteam = math.floor(totalsteam/#furnaces)
				--game.print(#furnaces .. " > " .. totalsteam .. " > " .. avgsteam)
				for _,furnace2 in pairs(furnaces) do
					furnace2.fluidbox[1] = {type="steam", amount=avgsteam}
				end
			end
			--]]
		end
	end
end

function tickGasBoilers(nvday, tick)
	--if tick%15 == 0 then
		for _,entry in pairs(nvday.gas_boilers) do
			if entry.input.valid then -- can be called before remove if race condition
				entry.input.set_recipe(entry.input.force.recipes["gas-boiler-input"]) --just to be safe
				local fluid = entry.input.fluidbox[1]
				if fluid and fluid.name == "petroleum-gas" and fluid.amount >= 1 then
					--game.print("Adding gas to boiler")
					if entry.boiler.fluidbox[1] and entry.boiler.fluidbox[1].name == "water" and entry.boiler.fluidbox[1].amount > 10 and tick%30 == 0 then
						fluid.amount = fluid.amount-1
						entry.input.fluidbox[1] = fluid
					end
					entry.boiler.burner.currently_burning = game.item_prototypes["coal"]
					entry.boiler.burner.remaining_burning_fuel = 8000000
					--entry.boiler.fluidbox[1] = {name = "steam", temperature = 100, amount=1}
				else
					entry.boiler.burner.remaining_burning_fuel = 0
				end
			else
				if entry.boiler.valid then
					entry.boiler.burner.remaining_burning_fuel = 0
				end
			end
		end
	--end
end

local function getGasBoilerEntry(nvday, entity)
	if entity.name == "gas-boiler" then
		for i, entry in ipairs(nvday.gas_boilers) do
			if entry.boiler.position.x == entity.position.x and entry.boiler.position.y == entity.position.y then
				return entry
			end
		end
	end
	if entity.name == "gas-boiler-input" then
		for i, entry in ipairs(nvday.gas_boilers) do
			if entry.input.position.x == entity.position.x and entry.input.position.y == entity.position.y then
				return entry
			end
		end
	end
	return nil
end

function rotateGasBoiler(nvday, entity)
  if entity.name == "gas-boiler" then
	local entry = getGasBoilerEntry(nvday, entity)
	local fluid = entry.input.fluidbox[1]
	local pos = entity.position
	if entity.direction == defines.direction.north then
		pos.y = pos.y+1
	end
	if entity.direction == defines.direction.south then
		pos.y = pos.y-1
	end
	if entity.direction == defines.direction.east then
		pos.x = pos.x-1
	end
	if entity.direction == defines.direction.west then
		pos.x = pos.x+1
	end
	entry.input.destroy()
	local gasinput = entity.surface.create_entity({name = "gas-boiler-input", position = pos, force = entity.force, direction = getOppositeDirection(entity.direction)})
	gasinput.set_recipe(entity.force.recipes["gas-boiler-input"])
	gasinput.fluidbox[1] = fluid
	entry.input = gasinput
  end
end

function addGasBoiler(nvday, entity)
  if entity.name == "gas-boiler" then
	local pos = entity.position
	--local pipepos = {x=pos.x, y=pos.y}
	if entity.direction == defines.direction.north then
		pos.y = pos.y+1
		--pipepos.y = pipepos.y+2
	end
	if entity.direction == defines.direction.south then
		pos.y = pos.y-1
		--pipepos.y = pipepos.y-2
	end
	if entity.direction == defines.direction.east then
		pos.x = pos.x-1
		--pipepos.x = pipepos.x-2
	end
	if entity.direction == defines.direction.west then
		pos.x = pos.x+1
		--pipepos.x = pipepos.x+2
	end
	local gasinput = entity.surface.create_entity({name = "gas-boiler-input", position = pos, force = entity.force, direction = getOppositeDirection(entity.direction)})
	table.insert(nvday.gas_boilers, {boiler = entity, input = gasinput})
	gasinput.set_recipe(entity.force.recipes["gas-boiler-input"])
	--local pipes = entity.surface.find_entities_filtered{position = pipepos}
  end
  if entity.type == "pipe" or entity.type == "pipe-to-ground" then
	local gasinputs = entity.surface.find_entities_filtered({name = "gas-boiler-input", area = {{entity.position.x-1, entity.position.y-1}, {entity.position.x+1, entity.position.y+1}}, force = entity.force})
	for _,input in pairs(gasinputs) do
		local e = input.energy
		local fluid = input.fluidbox[1]
		local dir = input.direction
		local pos = input.position
		local entry = getGasBoilerEntry(input)
		local rec = input.get_recipe()
		input.destroy()
		local repl = entity.surface.create_entity({name = "gas-boiler-input", force = entity.force, direction = dir, position = pos})
		repl.energy = e
		repl.set_recipe(rec)
		repl.fluidbox[1] = fluid
		entry.input = repl
		--game.print(repl.unit_number .. " : " .. (fluid and (fluid.name .. ":" .. fluid.amount) or "nil") .. " > " .. (entry.input.fluidbox[1] and (entry.input.fluidbox[1].name .. ":" .. entry.input.fluidbox[1].amount) or "nil"))
	end
  end
end

function removeGasBoiler(nvday, entity)
	if entity.name == "gas-boiler" then
		for i, entry in ipairs(nvday.gas_boilers) do
			if entry.boiler.position.x == entity.position.x and entry.boiler.position.y == entity.position.y then
				--local gasinputs = entity.surface.find_entities_filtered{name = "gas-boiler-input", position = entity.position}
				--gasinput.destroy()
				entry.input.destroy()
				table.remove(nvday.gas_boilers, i)
				break
			end
		end
	end
end

local function findNearbyRecipes(entity)
	local ret = nil
	local retct = 0
	local recipes = {}
	local furnaces = entity.surface.find_entities_filtered({name = entity.name, area = {{entity.position.x-8, entity.position.y-8}, {entity.position.x+8, entity.position.y+8}}})
	for _,furnace in pairs(furnaces) do
		local rec = furnace.get_recipe()
		if rec then
			if recipes[rec.name] == nil then
				recipes[rec.name] = 0
			end
			recipes[rec.name] = recipes[rec.name]+1
		end
	end
	for recipe,count in pairs(recipes) do
		--game.print(recipe .. ": " .. count)
		if ret == nil or count > retct then
			ret = recipe
			retct = count
		end
	end
	return ret and entity.force.recipes[ret] or nil
end

function addSteamFurnace(nvday, entity)
  if entity.name == "steam-furnace" or entity.name == "mixing-steam-furnace" or entity.name == "chemical-steam-furnace" then
	if entity.get_recipe() == nil then
		entity.set_recipe(findNearbyRecipes(entity))
	end
	
	--local pole = entity.surface.create_entity({name = "furnace-electric-pole", position = entity.position, force = entity.force})
	--local interface = entity.surface.create_entity({name = "furnace-energy-interface", position = entity.position, force = entity.force})	
	table.insert(nvday.steam_furnaces, entity--[[{furnace=entity, pole=pole, energy=interface}--]])
  end
end

function removeSteamFurnace(nvday, entity)
	if entity.name == "steam-furnace" or entity.name == "mixing-steam-furnace" or entity.name == "chemical-steam-furnace" then
		for i,--[[entry--]]furnace in ipairs(nvday.steam_furnaces) do
			if --[[entry.--]]furnace.position.x == entity.position.x and --[[entry.--]]furnace.position.y == entity.position.y then
				--entry.pole.destroy()
				--entry.energy.destroy()
				table.remove(nvday.steam_furnaces, i)
				break
			end
		end
	end
end

function addGreenhouse(nvday, entity)
  if entity.name == "greenhouse" then
	entity.set_recipe(entity.force.recipes["greenhouse-action"])
  end
end

function addBorehole(nvday, entity)
  if entity.name == "storage-machine" then
	local hole = entity.surface.find_entities_filtered({type = "resource", area = {{entity.position.x-1, entity.position.y-1}, {entity.position.x+1, entity.position.y+1}}})
	if #hole == 1 then
		if game.entity_prototypes[hole[1].name].resource_category == "borehole" then
			table.insert(nvday.boreholes, {well=entity, hole=hole[1]})
		end
	end
  end
end

function removeBorehole(nvday, entity)
  if entity.name == "storage-machine" then
	for i,entry in ipairs(nvday.boreholes) do
		if entry.well.position.x == entity.position.x and entry.well.position.y == entity.position.y then
			table.remove(nvday.boreholes, i)
			break
		end
	end
  end
end

function tickBoreholes(nvday, tick)
  if #nvday.boreholes > 0 and tick%30 == 0 then
	  for i=#nvday.boreholes,1,-1 do
		local entry = nvday.boreholes[i]
		if entry.hole.valid and entry.hole.name == "borehole" and entry.well.mining_progress > 0 then
			local pos = entry.hole.position
			local amt = entry.hole.amount
			local force = entry.hole.force
			entry.hole.destroy()
			entry.hole = entry.well.surface.create_entity{name="used-borehole", position=pos, amount=amt, force = force}
			local amt = entry.well.fluidbox[2] and entry.well.fluidbox[2].amount or 0
			entry.well.fluidbox[2] = {name="waste", amount=amt+2000}
			table.remove(nvday.boreholes, i)
		end
	  end
  end
end

local function calculateBoreholeSizeStep(amount)
	return math.max(10, math.min(250, 10*math.floor(amount/25/10)))
end

local function calculateCyclesForHoleSize(hole)
	local amt = hole and hole.amount or 0
	local val = 0
	for i = 1,maxBoreholeSize do
		val = val+calculateBoreholeSizeStep(val)
		if val >= amt then
			return i
		end
	end
	return maxBoreholeSize
end

function addBoreholeMaker(nvday, entity)
  if entity.name == "borer" then
	entity.set_recipe(entity.force.recipes["boring-action"])
	local holes = entity.surface.find_entities_filtered({type = "resource", name = "borehole", area = {{entity.position.x-1, entity.position.y-1}, {entity.position.x+1, entity.position.y+1}}, limit = 1})
	local hole = #holes == 1 and holes[1] or nil
	local s = calculateCyclesForHoleSize(hole)
	entity.products_finished = s
	table.insert(nvday.borers, {borer=entity, size = s, hole=hole})
  end
end

function removeBoreholeMaker(nvday, entity)
  if entity.name == "borer" then
	for i,entry in ipairs(nvday.borers) do
		if entry.borer.position.x == entity.position.x and entry.borer.position.y == entity.position.y then
			table.remove(nvday.borers, i)
			break
		end
	end
  end
end
--[[ do not use while resettable by break-and-replace
local function getBoreholeDrillTimeSubtraction(slot)
	local level = math.floor(slot/10)
	local factor = 1+level*0.0005+level*level*0.0000001
	local subtr = 1-(1/factor)
	return subtr
end
--]]

local function disableBorer(borer)
	local inv = borer.get_inventory(defines.inventory.assembling_machine_input)
	for i=1,#inv do
		local item = inv[i]
		borer.surface.spill_item_stack(borer.position, item, true)
	end
	borer.set_recipe(nil)
	borer.crafting_progress = math.min(borer.crafting_progress, 0.01)
	borer.order_deconstruction(borer.force)
end

function tickBoreholeMakers(nvday, tick)
  if #nvday.borers and tick%10 == 0 then
	  for _,entry in pairs(nvday.borers) do
		entry.borer.set_recipe(entry.borer.force.recipes["boring-action"])
		--game.print(entry.borer.products_finished .. " / " .. entry.size)
		--entry.borer.crafting_progress = math.max(0, entry.borer.crafting_progress-getBoreholeDrillTimeSubtraction(entry.size))
		if entry.hole == nil or entry.size < maxBoreholeSize then
			if entry.borer.products_finished > entry.size then
				entry.size = entry.size+1
				local hole = entry.hole
				if hole == nil then
					hole = entry.borer.surface.create_entity{name="borehole", position={entry.borer.position.x, entry.borer.position.y+1}, amount=10, force=game.forces.neutral} --fluid resources use units of 10
					--game.print("Creating new borehole")
					entry.hole = hole
				else
					local step = calculateBoreholeSizeStep(hole.amount)
					hole.amount = hole.amount+step --each unit of amount is worth 2k, remember
					--game.print("Deepening borehole to " .. hole.amount)
				end
				if entry.size >= maxBoreholeSize then
					disableBorer(entry.borer)
				end
			end
		else
			disableBorer(entry.borer)
		end
	  end
  end
end