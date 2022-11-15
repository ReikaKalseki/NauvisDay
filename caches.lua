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
		--game.print(n)
		--local recipe = entry.entity.force.recipes[n]
		local water = entry.entity.fluidbox[1]
		local sludge = entry.entity.fluidbox[2]
		local frac = entry.entity.crafting_progress
		entry.entity.set_recipe(n)
		--game.print(n .. " > " .. entry.entity.get_recipe().name)
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
			entity.operable = false
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