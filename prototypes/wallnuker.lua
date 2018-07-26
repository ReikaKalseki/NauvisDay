if not Config.enableWallNukers then return end

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

data:extend({
  {
    type = "unit",
    name = "wall-nuker",
    icon = "__base__/graphics/icons/small-biter.png",
    icon_size = 32,
    flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "not-repairable", "breaths-air"},
    max_health = 180,
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
      range = 0.0,
      cooldown = 12,--0,--35,
      ammo_category = "melee",
      ammo_type = make_unit_melee_ammo_type(0),
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
    corpse = "small-biter-corpse",
    dying_explosion = "blood-explosion-small",
    dying_sound =  make_biter_dying_sounds(0.4),
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

--table.insert(data["unit-spawner"]["biter-spawner"])