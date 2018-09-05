function addPollutionDetector(nvday, entity)
  --game.print("Adding " .. entity.name .. " @ " .. entity.position.x .. " , " .. entity.position.y)
  if entity.name == "pollution-detector" then
    addPDToTable(nvday, entity)
  end
end

function removePollutionDetector(nvday, entity)
	if entity.name == "pollution-detector" then
		for i, pollution_detector in ipairs(nvday.pollution_detectors) do
			if notNil(pollution_detector, "position") then
				if pollution_detector.position.x == entity.position.x and pollution_detector.position.y == entity.position.y then
					table.remove(nvday.pollution_detectors, i)
					break
				end
			end
		end
	end
end

function tickDetectors(nvday, tick)
  if tick%60 == 0 then
    for i, pollution_detector in ipairs(nvday.pollution_detectors) do
      setPollutionValue(pollution_detector)
    end   
  end
end

function addPDToTable(nvday, entity)
  --game.print("Registering " .. entity.name .. " @ " .. entity.position.x .. " , " .. entity.position.y)
  entity.operable = false
  table.insert(nvday.pollution_detectors, entity)
end

function notNil(class, var)
  value = false
  pcall(function()
    if class[var] then
      value = true
    end
  end)
  return value
end

function setPollutionValue(entity)
  pollution_count = math.floor(entity.surface.get_pollution({entity.position.x,entity.position.y}))
  if pollution_count < 0 or pollution_count > 2^32-1 then
	pollution_count = 0
  end
  params = {parameters = {
    {
		index = 1,
		signal = {type = "virtual", name = "pollution"},
		count = pollution_count
	}
  }}

  entity.get_control_behavior().parameters = params
end