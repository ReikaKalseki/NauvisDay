require "config"

require "prototypes.deaerosolizer"
require "prototypes.vent"
--require "prototypes.waterdump"
require "prototypes.wellstorage"

require "prototypes.detector"
require "prototypes.steamfurnace" --be like mining drills, can share steam; smelting is just recipes that use some steam; iterate over smelting recipe list; make pollute very little, maybe 8-12 = 1 steel furnace; crafting speed is betwene stone and steel
require "prototypes.gasboiler" --basis is just reskinned chemical plant; have be like boiler with new fluid input on 'back' for natural gas (aka petroleum gas); make gen 1/6 the pollution of a coal boiler (taking all multipliers into account, meaning =1/1.5 base since coal is x4 pollution)

require "prototypes.fluid"
require "prototypes.pollution-block"
require "prototypes.pollution-processing"

require "prototypes.tech"