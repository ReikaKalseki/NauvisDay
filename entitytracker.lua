require "functions"
require "caches"
require "constants"
require "config"
require "fans"

tracker = {
	["add"] = {},
	["remove"] = {},
	["tick"] = {}
}

local function addTracker(name, add, _remove, tick)
	tracker["add"][name] = add
	tracker["remove"][name] = _remove
	tracker["tick"][name] = tick
end

addTracker("steam-furnace",			addSteamFurnace,		removeSteamFurnace,			tickSteamFurnaces)
addTracker("gas-boiler",			addGasBoiler,			removeGasBoiler,			tickGasBoilers)
addTracker("pollution-detector",	addPollutionDetector,	removePollutionDetector,	tickDetectors)
addTracker("borer",					addBoreholeMaker,		removeBoreholeMaker,		tickBoreholeMakers)
addTracker("storage-machine",		addBorehole,			removeBorehole,				tickBoreholes)
addTracker("greenhouse",			addGreenhouse,			nil,						nil)
addTracker("pollution-fan",			addFan,					removeFan,					tickFans)
addTracker("pollution-fan-placer",	addFan,					removeFan,					nil)
addTracker("chemical-steam-furnace",addSteamFurnace,		removeSteamFurnace,			tickSteamFurnaces)
addTracker("mixing-steam-furnace",	addSteamFurnace,		removeSteamFurnace,			tickSteamFurnaces)