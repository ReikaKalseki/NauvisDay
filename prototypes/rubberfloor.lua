data:extend(
{
  {
    type = "item",
    name = "rubber-floor",
    icon = "__NauvisDay__/graphics/icons/rubber-floor.png",
	icon_size = 32,
    flags = {},
    subgroup = "terrain",
    order = "b[rubber-floor]-a[plain]",
    stack_size = 100,
    place_as_tile =
    {
      result = "rubber-floor",
      condition_size = 1,
      condition = { "water-tile" }
    }
  },
   {
    type = "recipe",
    name = "rubber-floor",
    category = "crafting",
    --order = "f[plastic-bar]-f[venting]",
    energy_required = 4,
    enabled = "true",
    ingredients =
    {
      {type="item", name="iron-plate", amount=10}
    },
    results=
    {
      {type="item", name="rubber-floor", amount=50}
    },
  }
}
)

local function createStepSounds()
	local ret = {}
	for i = 1,9 do
		local val = {
          filename = "__core__/sound/walking/transport-belt-0" .. i .. ".ogg",
          volume = 0.5
        }
		table.insert(ret, val)
	end
end

data:extend(
  {
    {
      type = "tile",
      name = "rubber-floor",
      needs_correction = false,
      minable = {mining_time = 0.5, result = "rubber-floor"},
      mined_sound = { filename = "__core__/sound/deconstruct-small.ogg" },
      collision_mask = {"ground-tile"},
      walking_speed_modifier = 1.3,
      layer = 61,
      decorative_removal_probability = 0.0,
    variants =
    {
      main =
      {
        {
          picture = "__NauvisDay__/graphics/terrain/rubber-floor/rubber-floor-1.png",
          count = 16,
          size = 1
        },
        {
          picture = "__NauvisDay__/graphics/terrain/rubber-floor/rubber-floor-2.png",
          count = 4,
          size = 2,
          probability = 0.39,
        },
        {
          picture = "__NauvisDay__/graphics/terrain/rubber-floor/rubber-floor-4.png",
          count = 4,
          size = 4,
          probability = 1,
        },
      },
      inner_corner =
      {
        picture = "__NauvisDay__/graphics/terrain/rubber-floor/rubber-floor-inner-corner.png",
        count = 8
      },
      outer_corner =
      {
        picture = "__NauvisDay__/graphics/terrain/rubber-floor/rubber-floor-outer-corner.png",
        count = 1
      },
      side =
      {
        picture = "__NauvisDay__/graphics/terrain/rubber-floor/rubber-floor-side.png",
        count = 10
      },
      u_transition =
      {
        picture = "__NauvisDay__/graphics/terrain/rubber-floor/rubber-floor-u.png",
        count = 10
      },
      o_transition =
      {
        picture = "__NauvisDay__/graphics/terrain/rubber-floor/rubber-floor-o.png",
        count = 10
      }
    },
      walking_sound = createStepSounds(),
      map_color={r=10, g=10, b=10},
      pollution_absorption_per_second=data.raw.tile["grass-1"].pollution_absorption_per_second, --multiple grass types now
      vehicle_friction_modifier = 0.8
    },
  })