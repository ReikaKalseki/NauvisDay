function addPollutionDetector(entity)
  if entity.name == "pollution-detector" then
    addPDToTable(entity)
  end
end

function removePollutionDetector(entity)
	if entity.name == "pollution-detector" then
		for i, pollution_detector in ipairs(global.nvday.pollution_detectors) do
			if notNil(pollution_detector, "position") then
				if pollution_detector.position.x == entity.position.x and pollution_detector.position.y == entity.position.y then
					table.remove(global.nvday.pollution_detectors, i)
					break
				end
			end
		end
	end
end

function tickDetectors(tick)
  if tick%60 == 0 then
    for i, pollution_detector in ipairs(global.nvday.pollution_detectors) do
      setPollutionValue(pollution_detector)
    end   
  end
end

function addPDToTable(entity)
  entity.operable = false
  table.insert(global.nvday.pollution_detectors, entity)
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
  params = {parameters = {
    {
		index = 1,
		signal = {type = "item", name = "pollution"},
		count = pollution_count
	}
  }}

  entity.get_control_behavior().parameters = params
end