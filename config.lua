Config = {}

Config.basePollutionFactor = settings.startup["base-pollution-factor"].value--1 --A multiplier for the pollution production. Multiplied against internal values. Increase this to make even MORE pollution.

Config.pollutedWaterThreshold = settings.startup["polluted-water-threshold"].value--20000 --the min amount of air pollution in a chunk before it will start contaminating the water
Config.cleanWaterThreshold = settings.startup["clean-water-threshold"].value--5000 --the max amount of air pollution in a chunk before contaminated water will start cleaning again; must be much (several times cleanup) less than the polluting threshold or you get water flipping back and forth
Config.pollutedWaterTileCleanup = settings.startup["polluted-water-tile-cleanup"].value--100 --the amount of air pollution removed when a water tile turns polluted and, if cleaned, released when it turns back
Config.pollutedWaterTileRelease = settings.startup["polluted-water-tile-release-factor"].value--1

Config.depleteWells = settings.startup["use-depleted-oil-for-well"].value--true

Config.enableSteamFurnace = settings.startup["steam-furnace"].value--true
Config.enableGasBoiler = settings.startup["gas-boiler"].value--true
Config.wallNukerThresh = settings.startup["wall-nuker-pollution"].value--true