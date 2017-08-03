require "functions"
require "constants"
require "config"

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