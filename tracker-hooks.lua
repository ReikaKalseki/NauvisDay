require "__DragonIndustries__/entitytracker"

require "functions"
require "caches"
require "constants"
require "config"
require "fans"

function getGlobal()
	return global.nvday
end

--remote.call("human interactor", "bye", "dear reader")

--not necessary anymore, with fluid power source addTracker("steam-furnace",					addSteamFurnace,		removeSteamFurnace,			tickSteamFurnaces,						"nvday",	getGlobal())
--addTracker("gas-boiler",					addGasBoiler,			removeGasBoiler,			tickGasBoilers)
addTracker("pollution-detector",			addPollutionDetector,	removePollutionDetector,	tickDetectors)
addTracker("borer",							addBoreholeMaker,		removeBoreholeMaker,		tickBoreholeMakers)
addTracker("storage-machine",				addBorehole,			removeBorehole,				tickBoreholes)
addTracker("storage-machine-2",				addBorehole,			removeBorehole,				tickBoreholes)
addTracker("greenhouse",					addGreenhouse,			nil,						nil)
addTracker("pollution-fan",					addFan,					removeFan,					tickFans)
addTracker("pollution-fan-placer",			addFan,					removeFan,					nil)
--addTracker("chemical-steam-furnace",		addSteamFurnace,		removeSteamFurnace,			nil)
--addTracker("mixing-steam-furnace",			addSteamFurnace,		removeSteamFurnace,			nil)

for i = 1,4 do
	addTracker("air-filter-machine-" .. i,	addDeaerosolizer,		removeDeaerosolizer,		i == 1 and tickDeaerosolizers or nil)
end