require "constants"
require "config"

require "__DragonIndustries__.recipe"

if not Config.enableSteamFurnace then return end

local power = 1--15

local function createAnimations(furnace)
	local ret = {
    animation =
    {
      layers = {
        {
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace.png",
          priority = "high",
          width = 85,
          height = 87,
          frame_count = 1,
          shift = util.by_pixel(-1.5, 1.5),
          hr_version = {
            filename = "__NauvisDay__/graphics/entity/steam-furnace/hr-steel-furnace.png",
            priority = "high",
            width = 171,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(-1.25, 2),
            scale = 0.5
          }
        },
        {
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace-shadow.png",
          priority = "high",
          width = 139,
          height = 43,
          frame_count = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(39.5, 11.5),
          hr_version = {
            filename = "__NauvisDay__/graphics/entity/steam-furnace/hr-steel-furnace-shadow.png",
            priority = "high",
            width = 277,
            height = 85,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(39.25, 11.25),
            scale = 0.5
          }
        },
      },
    },
    working_visualisations =
    {
      {
        north_position = {0.0, 0.0},
        east_position = {0.0, 0.0},
        south_position = {0.0, 0.0},
        west_position = {0.0, 0.0},
        animation =
        {
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace-fire.png",
          priority = "high",
          line_length = 8,
          width = 29,
          height = 40,
          frame_count = 48,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(-0.5, 6),
          hr_version = {
            filename = "__NauvisDay__/graphics/entity/steam-furnace/hr-steel-furnace-fire.png",
            priority = "high",
            line_length = 8,
            width = 57,
            height = 81,
            frame_count = 48,
            axially_symmetrical = false,
            direction_count = 1,
            shift = util.by_pixel(-0.75, 5.75),
            scale = 0.5
          }
        },
        light = {intensity = 1, size = 1, color = {r = 1.0, g = 1.0, b = 1.0}}
      },
      {
        north_position = {0.0, 0.0},
        east_position = {0.0, 0.0},
        south_position = {0.0, 0.0},
        west_position = {0.0, 0.0},
        effect = "flicker", -- changes alpha based on energy source light intensity
        animation =
        {
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace-glow.png",
          priority = "high",
          width = 60,
          height = 43,
          frame_count = 1,
          shift = {0.03125, 0.640625},
          blend_mode = "additive"
        }
      },
      {
        north_position = {0.0, 0.0},
        east_position = {0.0, 0.0},
        south_position = {0.0, 0.0},
        west_position = {0.0, 0.0},
        effect = "flicker", -- changes alpha based on energy source light intensity
        animation =
        {
          filename = "__NauvisDay__/graphics/entity/steam-furnace/steel-furnace-working.png",
          priority = "high",
          line_length = 8,
          width = 64,
          height = 75,
          frame_count = 1,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(0, -4.5),
          blend_mode = "additive",
          hr_version = {
            filename = "__NauvisDay__/graphics/entity/steam-furnace/hr-steel-furnace-working.png",
            priority = "high",
            line_length = 8,
            width = 130,
            height = 149,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            shift = util.by_pixel(0, -4.25),
            blend_mode = "additive",
            scale = 0.5
          }
        }
      },
    },
	}
	return ret
end

local function createIcons(obj)
	if not obj.icon then return end
	obj.icon = string.gsub(obj.icon, "__base__", "__NauvisDay__")
	obj.icon = string.gsub(obj.icon, "__bobplates__", "__NauvisDay__")
	obj.icon = string.gsub(obj.icon, "steel%-furnace", obj.name)
	obj.icon_size = 32
	obj.icon_mipmaps = 0
	--log(obj.icon)
end

local function createSteamPowerSource(original)
	local ret = {
		type = "fluid",
		fluid_box = {
			filter = "steam",
			production_type = "input",
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			base_area = 1,
			base_level = -1,
			pipe_connections = {
				{type = "input", positions = {{0.5, -1.5}, {1.5, -0.5}, {0.5, 1.5}, {-1.5, -0.5}}},
			},
			secondary_draw_orders = { north = -1 }
		  },
		  emissions_per_minute = original.emissions_per_minute/4,
		  effectivity = 1,
		  minimum_temperature = 100.0,
		  maximum_temperature = 1000.0,
		  scale_fluid_usage = true,
		  burns_fluid = false,
		  fluid_usage_per_tick = nil,
		  smoke = original.smoke
	}
	return ret
end

local function createSteamPoweredFurnace(base, upcraft)
	local obj = data.raw["furnace"][base]
	if not obj then obj = data.raw["assembling-machine"][base] end
	if not obj then return end

	local furnace = table.deepcopy(obj)
	local anim = createAnimations(furnace)
	if string.find(furnace.name, "steel") then
		furnace.name = string.gsub(furnace.name, "steel", "steam")
	else
		furnace.name = "steam-" .. furnace.name
	end
	furnace.localised_name = {"steam-furnace.name", {"entity-name." .. base}}
	furnace.energy_source = createSteamPowerSource(furnace.energy_source)
	furnace.crafting_speed = furnace.crafting_speed*Config.steamFurnaceSpeed
	furnace.minable.result = furnace.name
	furnace.animation = anim.animation
	furnace.working_visualisations = anim.working_visualisations
	createIcons(furnace)
	
	local item = table.deepcopy(data.raw.item[base])
	item.name = furnace.name
	item.place_result = item.name
	createIcons(item)
  
	local recipe = {
	type = "recipe",
	name = furnace.name,
	energy_required = 3.5,
	enabled = "false",
	ingredients = {
		{base, 1},
		{"pipe", 10},
		{"stone", 5},
	},
	result = furnace.name,
  }
	createIcons(recipe)
	--[[
	if mods["EarlyExtensions"] then
		recipe.ingredients = {
			{"stone-furnace", 1},
			{"pipe", 15},
			{"stone-brick", 5},
		}
		furnace.localised_name = {"steam-furnace.name", {"entity-name.stone-furnace"}}
	end
	--]]
	
	item.localised_name = furnace.localised_name
	
	log("Creating a steam-powered version of " .. base)
	data:extend({furnace, item, recipe})
	
	local rec = createConversionRecipe(recipe.name, upcraft, false, nil, true)
	rec.enabled = false
	rec.name = recipe.name .. "-upcraft"
	local unc = createUncraftingRecipe(recipe, item)
	unc.energy_required = 0.5
	data:extend({rec, unc})
end

createSteamPoweredFurnace("steel-furnace", "electric-furnace")
createSteamPoweredFurnace("chemical-steel-furnace", "electric-chemical-furnace")
createSteamPoweredFurnace("mixing-steel-furnace", "electric-mixing-furnace")

local rec = createConversionRecipe("stone-furnace", "steam-furnace", false, nil, true)
rec.enabled = false
rec.name = "stone-to-steam-furnace"
rec.energy_required = data.raw.recipe["steam-furnace"].energy_required
data:extend({rec})