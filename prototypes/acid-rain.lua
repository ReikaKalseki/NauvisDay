local DAMAGE_RATE = 5 -- per second
local TICK_RATE = 5 -- cycles per second

local function generateRainSprite(size, dx, dy)
	return
	{
	  filename = "__NauvisDay__/graphics/entity/acid-rain/attempt2/rain2_strip_48.png",
	  flags = {},
	  priority = "low",
	  width = 256,
	  height = 128,
	  frame_count = 48,
	  animation_speed = 1.5,
	  line_length = 16,
	  scale = size/6,
	  shift = {dx, dy}
	}
end

local function createCloud(name, size, total_damage)
	local duration = total_damage/DAMAGE_RATE
	local ret = {
    type = "smoke-with-trigger",
    name = "acid-rain-" .. name,
    flags = {"not-on-map"},
    show_when_smoke_off = true,
    animation =
    {
		layers = 
		{
			{
			  filename = "__NauvisDay__/graphics/entity/acid-rain/attempt2/complete.png",
			  flags = {},
			  priority = "low",
			  width = 256,
			  height = 256,
			  frame_count = 48,
			  animation_speed = 0.5,
			  line_length = 8,
			  scale = size/2,
			  tint = {r = 1, g = 1, b = 1, a = 0},
			  --run_mode = "forward-then-backward",
			},
			generateRainSprite(size, -size/2, -size/2),
			generateRainSprite(size, size/2, -size/2),
			generateRainSprite(size, -size/2, 0),
			generateRainSprite(size, size/2, 0),
			generateRainSprite(size, -size/2, size/2),
			generateRainSprite(size, size/2, size/2)
		}
    },
    slow_down_factor = 0,
    affected_by_wind = true,
    cyclic = true,
    duration = math.ceil(60 * duration),
    fade_away_duration = math.ceil((duration/3) * 60),
    spread_duration = math.ceil((duration/3) * 60),
    color = { r = 131/255, g = 180/255, b = 185/255 },
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
            entity_flags = {"placeable-player", "player-creation"},
            action_delivery =
            {
              type = "instant",
              target_effects =
			  {
				  {
					type = "damage",
					damage = { amount = DAMAGE_RATE/TICK_RATE, type = "acid"}
				  }
			  }
            }
          }
        }
      }
    },
    action_cooldown = 60/TICK_RATE
  }
  return ret
end

data:extend({
	createCloud("small", 5, 10),
	createCloud("medium", 8, 25),
	createCloud("big", 12, 50),
	createCloud("huge", 18, 100),
})