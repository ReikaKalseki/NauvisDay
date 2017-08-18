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
            perimeter = size,
            entity_flags = {"breaths-air"},
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = damage, type = "poison"}
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