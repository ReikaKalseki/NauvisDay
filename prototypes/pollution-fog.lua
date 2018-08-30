local function createCloud(name, duration, size, damage)
	local ret = {
    type = "smoke-with-trigger",
    name = "pollution-fog-" .. name,
    flags = {"not-on-map"},
    show_when_smoke_off = true,
    animation =
    {
      filename = "__NauvisDay__/graphics/entity/cloud/cloud-45-frames.png",
      flags = {},
      priority = "low",
      width = 256,
      height = 256,
      frame_count = 45,
      animation_speed = 0.25,
      line_length = 7,
      scale = size/2,
	  run_mode = "backward",
    },
    slow_down_factor = 0,
    affected_by_wind = true,
    cyclic = true,
    duration = math.ceil(60 * duration),
    fade_away_duration = math.ceil((duration/3) * 60),
    spread_duration = math.ceil((duration/3) * 60),
    color = { r = 0.2696, g = 0.2361, b = 0.1196 },
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "nested-result",
          action =
          {
            type = "area",
            radius = size,
            entity_flags = {"breaths-air"},
            action_delivery =
            {
              type = "instant",
              target_effects =
			  {
				  {
					type = "damage",
					damage = { amount = damage, type = "poison"}
				  },--[[
				  {
					type = "play-sound",
					sound = {
						filename = "__NauvisDay__/sound/gasp.ogg",
						aggregation =
						{
						   max_count = 1,
						   
						   -- if false (default), max_count limits only number on instances that can be started at the same tick
						   count_already_playing = true,
						   
						   -- from interval 0.0 to 1.0 (default 1.0); how much of the sound should be played before it shouldn't be counted towards max_count anymore
						   progress_threshold = 1.0,
						   
						   -- if true, new instances of the sound are not created if max_count was reached;
						   -- if false, volume of the new instances of the sound is decresed by multiplying it by count^(-0.45)
						   remove = true
						}
					},
					action_cooldown = 4*60
				  }--]]
			  }
            }
          }
        }
      }
    },
    action_cooldown = 10
  }
  return ret
end

data:extend({
	createCloud("small", 2, 4, 0),
	createCloud("medium", 4, 10, 0.1),
	createCloud("big", 10, 15, 0.3),
	createCloud("huge", 15, 27, 1),
})