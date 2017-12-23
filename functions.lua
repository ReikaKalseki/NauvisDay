require "config"
require "constants"

function directionToVector(dir)
	if dir == defines.direction.north then
		return {dx=0, dy=-1}
	elseif dir == defines.direction.south then
		return {dx=0, dy=1}
	elseif dir == defines.direction.east then
		return {dx=1, dy=0}
	elseif dir == defines.direction.west then
		return {dx=-1, dy=0}
	end
end

function getOppositeDirection(dir) --direction is a number from 0 to 7
	return (dir+4)%8
end

function getPerpendicularDirection(dir) --direction is a number from 0 to 7
	return (dir+2)%8
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
			if fluids[ingredient.name] < ingredient.amount then
				return false
			end
		end
	end
	return true
end

function tickSteamFurnaces(nvday, tick)
	if tick%30 == 0 then
		for _,furnace in pairs(nvday.steam_furnaces) do
			if furnace.get_recipe() and hasIngredients(furnace) then
				furnace.crafting_progress = math.max(furnace.crafting_progress, 0.005)
			end
			local fluid = furnace.fluidbox[1]
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
					if entry.boiler.fluidbox[1] and entry.boiler.fluidbox[1].name == "water" and entry.boiler.fluidbox[1].amount > 10 and tick%4 == 0 then
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
  if entity.name == "steam-furnace" then
	entity.set_recipe(findNearbyRecipes(entity))
	
	--local pole = entity.surface.create_entity({name = "furnace-electric-pole", position = entity.position, force = entity.force})
	--local interface = entity.surface.create_entity({name = "furnace-energy-interface", position = entity.position, force = entity.force})	
	table.insert(nvday.steam_furnaces, entity--[[{furnace=entity, pole=pole, energy=interface}--]])
  end
end

function removeSteamFurnace(nvday, entity)
	if entity.name == "steam-furnace" then
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
			entry.well.fluidbox[2] = {type="waste", amount=amt+2000}
			table.remove(nvday.boreholes, i)
		end
	  end
  end
end

function addBoreholeMaker(nvday, entity)
  if entity.name == "borer" then
	entity.set_recipe(entity.force.recipes["boring-action"])
	local holes = entity.surface.find_entities_filtered({type = "resource", name = "borehole", area = {{entity.position.x-1, entity.position.y-1}, {entity.position.x+1, entity.position.y+1}}})
	table.insert(nvday.borers, {borer=entity, size = 0, hole=#holes == 1 and holes[1] or nil}) --set size to zero, since products_finished is read only
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
		if entry.hole == nil or entry.hole.amount < maxBoreholeSize then
			if entry.borer.products_finished > entry.size then
				entry.size = entry.size+1
				local hole = entry.hole
				if hole == nil then
					hole = entry.borer.surface.create_entity{name="borehole", position={entry.borer.position.x, entry.borer.position.y+1}, amount=10, force=game.forces.neutral} --fluid resources use units of 10
					--game.print("Creating new borehole")
					entry.hole = hole
				else
					hole.amount = hole.amount+10
					--game.print("Deepening borehole to " .. hole.amount)
				end
				if hole.amount >= maxBoreholeSize then
					disableBorer(entry.borer)
				end
			end
		else
			disableBorer(entry.borer)
		end
	  end
  end
end

function getMaxEnemyWaveSize(evo)
	if evo <= 0 then
		return maxAttackSizeCurve[1][2]
	end
	local idx = 1
	while idx <= #maxAttackSizeCurve and maxAttackSizeCurve[idx][1] < evo do
		idx = idx+1
	end
	idx = idx-1
	--game.print("Evo of " .. evo .. " > idx= " .. idx .. ": " .. maxAttackSizeCurve[idx][1] .. "," .. maxAttackSizeCurve[idx][2] .. " & " .. maxAttackSizeCurve[idx+1][1] .. "," .. maxAttackSizeCurve[idx+1][2])
	local x1 = maxAttackSizeCurve[idx][1]
	local x2 = maxAttackSizeCurve[idx+1][1]
	local y1 = maxAttackSizeCurve[idx][2]
	local y2 = maxAttackSizeCurve[idx+1][2]
	return math.ceil(y1+(y2-y1)*((evo-x1)/(x2-x1)))
end

function setPollutionAndEvoSettings()
	for category, params in pairs(pollutionAndEvo) do
		for entry, val in pairs(params) do
			--game.print("Checking param " .. entry .. "...map val = " .. game.map_settings[category][entry] .. ", target = " .. val)
			if game.map_settings[category][entry] ~= val then
				game.print("NauvisDay: Re-setting " .. category .. "." .. entry .. " to " .. val .. " (was " .. game.map_settings[category][entry] .. ")")
				game.map_settings[category][entry] = val
			end
		end
	end
	if game.surfaces["nauvis"].peaceful_mode or game.surfaces["nauvis"].map_gen_settings.peaceful_mode then
		game.print("NauvisDay: Disabling peaceful mode.")
	end
	game.surfaces["nauvis"].peaceful_mode = false
	game.surfaces["nauvis"].map_gen_settings.peaceful_mode = false
	--game.surfaces["nauvis"].autoplace_controls
end

function doTreeFarmTreeDeath(entity)
	--game.print(entity.name .. " & " .. (entity.type == "tree" and "true" or " false") .. " & " .. (string.find(entity.name, "tree") and "true" or " false") .. " & " .. (string.find(entity.name, "tf-", 1, true) and "true" or " false"))
	if entity.type == "tree" and string.find(entity.name, "tree") and string.find(entity.name, "tf-", 1, true) then
		local ret = entity.surface.create_entity({name="dead-tf-tree", position={entity.position.x, entity.position.y}, direction=entity.direction, force=entity.force})
	end
end

function getPossibleBiters(curve, evo)
	local ret = {}
	local totalWeight = 0
	for _,entry in pairs(curve) do
		local biter = entry.unit
		local vals = entry.spawn_points -- eg "{0.5, 0.0}, {1.0, 0.4}"
		for idx = 1,#vals do
			local point = vals[idx]
			local ref = point.evolution_factor
			local chance = point.weight
			if evo >= ref then
				local interp = 0
				if idx == #vals then
					interp = chance
				else
					interp = chance+(vals[idx+1].weight-chance)*(vals[idx+1].evolution_factor-ref)
				end
				if interp > 0 then
					table.insert(ret, {biter, interp+totalWeight})
					totalWeight = totalWeight+interp
					--game.print("Adding " .. biter .. " with weight " .. interp)
				end
				break
			end
		end
	end
	--game.print("Fake Evo " .. evo)
	--for i=1,#ret do game.print(ret[i][1] .. ": " .. ((i == 1 and 0 or ret[i-1][2]) .. " -> " .. ret[i][2])) end
	return ret, totalWeight
end

function selectWeightedBiter(biters, total)
	local f = math.random()*total
	local ret = "nil"
	local smallest = 99999999
	for i = 1,#biters do
		if f <= biters[i][2] and smallest > biters[i][2] then
			smallest = biters[i][2]
			ret = biters[i][1]
		end
	end
	--game.print("Selected " .. ret .. " with " .. f .. " / " .. total)
	return ret
end

function getSpawnedBiter(curve, evo)
	--game.print("Real Evo " .. evo)
	if math.random() < 0.5 then
		evo = evo-0.1
	end
	if math.random() < 0.25 then
		evo = evo-0.1
	end
	evo = math.max(evo, 0)
	local biters, total = getPossibleBiters(curve, evo)
	return selectWeightedBiter(biters, total)
end

function doSpawnerDestructionSpawns(spawner)
	if spawner.type == "unit-spawner" then
		local num = math.random(2, 20)
		for i = 1,num do
			local pos = {spawner.position.x, spawner.position.y}
			local data = spawner.prototype.result_units--game.entity_prototypes[spawner.type][spawner.name]--spawner.prototype
			local r = 10--data.spawning_radius
			pos[1] = pos[1]-r+math.random()*2*r
			pos[2] = pos[2]-r+math.random()*2*r
			local biter = getSpawnedBiter(data, spawner.force.evolution_factor)
			spawner.surface.create_entity{name=biter, position=pos, force = spawner.force}
		end
	end
end

function noSignificantBuilding()
	for struct,num in pairs(attackGreenlightingTypes) do
		if game.entity_prototypes[struct] and game.forces.player.get_entity_count(struct) >= num then
			return false
		end
	end
	return true
end

function playerNearSpawner()
	for _,player in pairs(game.players) do
		local nearspawner = player.surface.find_nearest_enemy{position=player.position, max_distance = 45, force = player.force}
		if nearspawner then
			return true
		end
	end
	return false
end

function ensureNoEarlyAttacks(tick)
	--game.map_settings.unit_group.max_gathering_unit_groups = 2 --default 30
	--game.map_settings.unit_group.max_unit_group_size = 5 --default 200
	--game.map_settings.unit_group.min_group_gathering_time = 3600*5 --default 3600=60s
	--game.map_settings.unit_group.max_group_gathering_time = game.map_settings.unit_group.min_group_gathering_time*10 --default 10x min
	if tick%1800 == 0 then --once per 30s
		if  game.forces.enemy.evolution_factor < 0.01 and (tick < 18000--[[60*60*5--]] or game.forces.enemy.evolution_factor < 0.004 or (game.forces.player and noSignificantBuilding())) then --less than five minutes into the game, or basically no pollution emission/construction (0.4% evo)
			--set peaceful mode until some threshold tick? or built some structures
			--or try destroy units, or max size of attack = 0 -> modify map_settings.unit group to change attacks, but problem is will probably result in MASSIVE first attack; would also conflict with NatEvo
			if not playerNearSpawner() then
				game.forces.enemy.kill_all_units()
			end
		end
	end
end

function getWeightedRandom(vals)
	local sum = 0
	for _,entry in pairs(vals) do
		local weight = entry[1]
		sum = sum+weight
	end
	
	--Copied and Luafied from DragonAPI WeightedRandom
	local d = math.random()*sum;
	local p = 0
	for _,entry in pairs(vals) do
		p = p + entry[1]
		if d <= p then
			return entry[2]
		end
	end
	return nil
end

function fluidSpill(e)
	if #e.fluidbox > 0 then
		for b = 1, #e.fluidbox do
		  if e.fluidbox[b] and e.fluidbox[b].name == "waste" then
			local spill_amount = e.fluidbox[b].amount
			-- debug("pollute! " .. position.x .. "," .. position.y .. " " .. corpse_size * settings.global['pollution_intensity'].value * spill_amount * 20)
			e.surface.pollute(e.position, --[[settings.global['pollution_intensity'].value * --]]spill_amount * 20)
		  end
		end
	end
end

function checkPollutionBlock(entity)
	if entity.name == "pollution-block" then
		entity.surface.pollute(entity.position, --[[settings.global['pollution_intensity'].value * --]]200)
	end
end