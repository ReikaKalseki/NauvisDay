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

addTracker("steam-furnace",					addSteamFurnace,		removeSteamFurnace,			tickSteamFurnaces,						"nvday",	getGlobal())
addTracker("gas-boiler",					addGasBoiler,			removeGasBoiler,			tickGasBoilers,							"nvday",	getGlobal())
addTracker("pollution-detector",			addPollutionDetector,	removePollutionDetector,	tickDetectors,							"nvday",	getGlobal())
addTracker("borer",							addBoreholeMaker,		removeBoreholeMaker,		tickBoreholeMakers,						"nvday",	getGlobal())
addTracker("storage-machine",				addBorehole,			removeBorehole,				tickBoreholes,							"nvday",	getGlobal())
addTracker("greenhouse",					addGreenhouse,			nil,						nil,									"nvday",	getGlobal())
addTracker("pollution-fan",					addFan,					removeFan,					tickFans,								"nvday",	getGlobal())
addTracker("pollution-fan-placer",			addFan,					removeFan,					nil,									"nvday",	getGlobal())
addTracker("chemical-steam-furnace",		addSteamFurnace,		removeSteamFurnace,			nil,									"nvday",	getGlobal())
addTracker("mixing-steam-furnace",			addSteamFurnace,		removeSteamFurnace,			nil,									"nvday",	getGlobal())

for i = 1,4 do
	addTracker("air-filter-machine-" .. i,	addDeaerosolizer,		removeDeaerosolizer,		i == 1 and tickDeaerosolizers or nil,	"nvday",	getGlobal())
end