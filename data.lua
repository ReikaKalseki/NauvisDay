require "config"

require "prototypes.deaerosolizer"
require "prototypes.greenhouse" --make work better in certain biomes?

require "prototypes.fan"

require "prototypes.vent"
--require "prototypes.waterdump"
require "prototypes.wellstorage"
require "prototypes.borer" --have a "borer" (assembling machine), which digs a hole, aka making a resource and setting its amount++; make each unit take more time than the last, at first linear, then quadratic; has limit on size, say 1M units; can be removed early, but will lock to that size if used (see below); autodeconstructs if reaches maxsize
--require "prototypes.borestorage" --another mining drill, like wellstorage, but converts the borehole to a "used borehole" (on first completion), aka "can never be expanded again", takes sludge and decrements resource amount
--not necessary; reuse well

require "prototypes.detector"
require "prototypes.steamfurnace"
require "prototypes.gasboiler"

require "prototypes.rubberfloor"

require "prototypes.fluid"
require "prototypes.borehole"

require "prototypes.pollution-block"
require "prototypes.asphalt"
require "prototypes.pollution-processing"

require "prototypes.pollution-fog"

require "prototypes.tech"