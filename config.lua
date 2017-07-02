Config = {}

Config.basePollutionFactor = 1 --A multiplier for the pollution production. Multiplied against internal values. Increase this to make even MORE pollution.

Config.pollutedWaterThreshold = 10000 --the min amount of air pollution in a chunk before it will start contaminating the water
Config.cleanWaterThreshold = 2000 --the max amount of air pollution in a chunk before contaminated water will start cleaning again; must be much (several times cleanup) less than the polluting threshold or you get water flipping back and forth
Config.pollutedWaterTileCleanup = 100 --the amount of air pollution removed when a water tile turns polluted and, if cleaned, released when it turns back