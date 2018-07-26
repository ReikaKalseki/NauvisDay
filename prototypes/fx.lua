data:extend({
  {
    type = "explosion",
    name = "wall-explosion",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = "__NauvisDay__/graphics/entity/wall-explosion.png",
        priority = "high",
		scale = 0.25,
        width = 324,
        height = 414,
        frame_count = 18,
        animation_speed = 0.5,
        stripes =
        {
          {
            filename = "__NauvisDay__/graphics/entity/wall-explosion.png",
            width_in_frames = 6,
            height_in_frames = 3
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
        max_count = 1,
        remove = true
      },
      variations =
      {
        {
          filename = "__NauvisDay__/sound/wall-collapse.ogg",
          volume = 0.75
        },
      }
    },
    created_effect =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-particle",
            repeat_count = 2,--5,
            entity_name = "explosion-remnants-particle",
            initial_height = 0.25,
            speed_from_center = 0.03,
            speed_from_center_deviation = 0.05,
            initial_vertical_speed = 0.03,
            initial_vertical_speed_deviation = 0.05,
            offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}}
          }
        }
      }
    }
  },
})