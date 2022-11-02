local speed = 1.6

local function create_attack_animation()
  local scale = 0.5
  return
  {
    layers=
    {
      {
        width = 157,
        height = 94,
        frame_count = 7,
        direction_count = 1,
        --shift = {scale * 1.74609, scale * -0.644531},
        animation_speed = speed,
        scale = scale,
        run_mode = "forward-then-backward",
        stripes =
        {
         {
          filename = "__NauvisDay__/graphics/entity/wall-nuker/attack.png",
          width_in_frames = 7,
          height_in_frames = 1
         },
        }
      },
    }
  }
end

local function create_animation()
local scale = 0.5
  return
  {
    layers=
    {
      {
        width = 157,
        height = 94,
        frame_count = 7,
        direction_count = 1,--16,
        --shift = {scale * 0.714844, scale * -0.246094},
        scale = scale,
        animation_speed = speed,
        run_mode = "forward-then-backward",
        stripes =
        {
         {
          filename = "__NauvisDay__/graphics/entity/wall-nuker/fly.png",
          width_in_frames = 7,
          height_in_frames = 1
         },
        }
      },
    }
  }
end

local sounds = require ("__base__.prototypes.entity.sounds")

data:extend({
{
	type = "virtual-signal",
	name = "nuker-alert",
	icon = "__NauvisDay__/graphics/icons/nuker-alert.png",
	icon_size = 64,
	subgroup = "virtual-signal-special",
	order = name,
	hidden = true,
},
  {
    type = "simple-entity-with-force",
    name = "soft-resin-egg",
    icon = "__NauvisDay__/graphics/icons/resin-egg.png",
	icon_size = 32,
    flags = {"placeable-enemy", "placeable-off-grid", "not-repairable", "breaths-air"},
    max_health = 3000,
    order = "b-b-a",
    subgroup="enemies",
	collision_mask = {"ground-tile"},--{"item-layer", "object-layer", "player-layer"},
	order = "z",
    render_layer = "object",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
	is_military_target = true,
    dying_explosion = "medium-worm-die",
    corpse = "resin-egg-corpse",
    dying_sound = sounds.worm_dying_small(0.65),
    animations =
    {
      filename = "__NauvisDay__/graphics/entity/worm-egg.png",
      priority = "high",
      width = 143,
      height = 120,
      apply_projection = false,
	  run_mode = "forward-then-backward",
      frame_count = 5,
      line_length = 5,
      shift = {0, 0},
	  scale = 0.5,
      animation_speed = 0.1,
    },
  },
  {
    type = "corpse",
    name = "resin-egg-corpse",
    icon = "__NauvisDay__/graphics/icons/resin-egg.png",
    icon_size = 32,
    selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selectable_in_game = false,
    subgroup="corpses",
    order = "c[corpse]-c[worm]-b[medium]",
    flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-repairable", "not-on-map"},
    dying_speed = 0.01,
    time_before_removed = 15 * 60 * 60,
    final_render_layer = "lower-object-above-shadow",
    animation =
    {
		direction_count = 1,
      filename = "__NauvisDay__/graphics/entity/worm-egg-die.png",
      priority = "high",
      width = 143,
      height = 104,
      apply_projection = false,
      frame_count = 1,
      line_length = 1,
      shift = {0.0, 0.1},
	  scale = 0.5,
    },
  },
  {
    type = "unit",
    name = "wall-nuker",
    icon = "__base__/graphics/icons/small-biter.png",
    icon_size = 32,
    flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "not-repairable", "breaths-air"},
    max_health = 2400,
    order = "b-b-a",
    subgroup="enemies",
    healing_per_tick = 0.05,
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.4, -0.7}, {0.7, 0.4}},
	has_belt_immunity = true,
	collision_mask = {}, --flying
    attack_parameters =
    {
		type = "projectile",
		range = 0.25,
		cooldown = 12,--0,--35,
		ammo_category = "melee",
		ammo_type = make_unit_melee_ammo_type(0.1),
		sound = {
			{
			  filename = "__NauvisDay__/sound/wallnuker-detonate.ogg",
			  volume = volume
			},
		},
		animation = create_attack_animation()
    },
    vision_distance = 90,
    movement_speed = 0.05,
    distance_per_frame = 0.1,
    pollution_to_join_attack = 2400,
    distraction_cooldown = 300,
    min_pursue_time = 10 * 60,
    max_pursue_distance = 50,
    --corpse = "small-biter-corpse",
    dying_explosion = "blood-explosion-small",
    dying_sound =  sounds.biter_dying(0.4),
    working_sound = {
		{
		  filename = "__NauvisDay__/sound/wallnuker.ogg",
		  volume = 1
		}
	},
    run_animation = create_animation()
  },
  {
    type = "explosion",
    name = "wall-nuker-explosion",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = "__NauvisDay__/graphics/entity/wall-nuker/explosion.png",
        priority = "high",
        width = 197,
        height = 245,
        frame_count = 24,
        animation_speed = 0.25,
		shift = {0, -1},
		scale = 2,
        stripes =
        {
          {
            filename = "__NauvisDay__/graphics/entity/wall-nuker/explosion.png",
            width_in_frames = 6,
            height_in_frames = 4
          },
        }
      },
    },
    light = {intensity = 1, size = 20, color = {r=1.0, g=1.0, b=1.0}},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1,
    sound =
    {
      aggregation =
      {
        max_count = 2,
        remove = true
      },
      variations =
      {
        {
          filename = "__NauvisDay__/sound/wallnuker-explode.ogg",
          volume = 0.75
        },
      }
    },
}
})

local function createNukedArea()
	local tile = table.deepcopy(data.raw.tile["red-desert-1"])
	
	tile.name = "nuker-goo"
	tile.autoplace = nil
	--log("Inserting " .. name .. " into " .. (tile.allowed_neighbors and (#tile.allowed_neighbors .. " @ " .. name) or "nil") .. " for " .. tile.name)
	tile.pollution_absorption_per_second = 0
	tile.map_color={r=83, g=28, b=105} --out of 255
	tile.collision_mask = data.raw.tile["water-mud"].collision_mask
	
    tile.variants = tile_variations_template(
      "__NauvisDay__/graphics/terrain/nukergoo/base.png", "__base__/graphics/terrain/masks/transition-1.png",
      "__NauvisDay__/graphics/terrain/nukergoo/hr.png", "__base__/graphics/terrain/masks/hr-transition-1.png",
      {
        max_size = 4,
        [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
        [2] = { probability = 1, weights = {0.070, 0.070, 0.025, 0.070, 0.070, 0.070, 0.007, 0.025, 0.070, 0.050, 0.015, 0.026, 0.030, 0.005, 0.070, 0.027 }, },
        [4] = { probability = 1.00, weights = {0.070, 0.070, 0.070, 0.070, 0.070, 0.070, 0.015, 0.070, 0.070, 0.070, 0.015, 0.050, 0.070, 0.070, 0.065, 0.070 }, },
        -- [8] = { probability = 1.00, weights = {0.090, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.025, 0.125, 0.005, 0.010, 0.100, 0.100, 0.010, 0.020, 0.020} }
      }
    )

    tile.walking_sound =
    {
      {
        filename = "__NauvisDay__/sound/nuker-goo/step1.ogg",
        volume = 0.8
      },
      {
        filename = "__NauvisDay__/sound/nuker-goo/step2.ogg",
        volume = 0.8
      },
      {
        filename = "__NauvisDay__/sound/nuker-goo/step3.ogg",
        volume = 0.8
      },
      {
        filename = "__NauvisDay__/sound/nuker-goo/step4.ogg",
        volume = 0.8
      }
    }
    tile.vehicle_friction_modifier = 25 --glue basically
    tile.walking_speed_modifier = 1/2.5
    tile.can_be_part_of_blueprint = false
	
	return tile
end

data:extend({createNukedArea()})

--table.insert(data["unit-spawner"]["biter-spawner"])