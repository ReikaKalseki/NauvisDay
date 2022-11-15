Config = {}

Config.basePollutionFactor = math.max(1, settings.startup["base-pollution-factor"].value--[[@as number]])

Config.pollutedWaterThreshold = settings.startup["polluted-water-threshold"].value--[[@as number]]
Config.cleanWaterThreshold = settings.startup["clean-water-threshold"].value--[[@as number]]
Config.pollutedWaterTileCleanup = settings.startup["polluted-water-tile-cleanup"].value--[[@as number]]
Config.pollutedWaterTileRelease = settings.startup["polluted-water-tile-release-factor"].value--[[@as number]]

Config.acidRainThreshold = settings.startup["acid-rain-threshold"].value--[[@as number]]

Config.depleteWells = settings.startup["use-depleted-oil-for-well"].value--[[@as boolean]]

Config.enableSteamFurnace = settings.startup["steam-furnace"].value--[[@as boolean]]
Config.enableGasBoiler = settings.startup["gas-boiler"].value--[[@as boolean]]
Config.enableRefinery = settings.startup["clean-refinery"].value--[[@as boolean]]

Config.wallNukerThresh = settings.startup["wall-nuker-pollution"].value--[[@as boolean]]

Config.steamFurnaceSpeed = settings.startup["steam-furnace-speed"].value--[[@as boolean]]
Config.cleanRefinerySpeed = settings.startup["clean-refinery-speed"].value--[[@as boolean]]

Config.attackSize = settings.startup["attack-size"].value--[[@as boolean]]

Config.pollutionChem = settings.startup["pollution-chem"].value--[[@as boolean]]
Config.pollutionChemOut = settings.startup["pollution-chem-out"].value--[[@as boolean]]