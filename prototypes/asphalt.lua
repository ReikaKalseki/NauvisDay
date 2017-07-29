data:extend(
{
  {
    type = "item",
    name = "asphalt",
    icon = "__NauvisDay__/graphics/icons/concrete.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "terrain",
    order = "b[asphalt]-a[plain]",
    stack_size = 100,
    place_as_tile =
    {
      result = "asphalt",
      condition_size = 4,
      condition = { "water-tile" }
    }
  }
}
)  data:extend(
  {
    {
      type = "tile",
      name = "asphalt",
      needs_correction = false,
      minable = {hardness = 0.2, mining_time = 0.5, result = "asphalt"},
      mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
      collision_mask = {"ground-tile"},
      walking_speed_modifier = 1.6,
      layer = 61,
      decorative_removal_probability = 1.0,
      variants =
      {
        main =
        {
          {
            picture = "__NauvisDay__/graphics/terrain/concrete/concrete1.png",
            count = 16,
            size = 1
          },
          {
            picture = "__NauvisDay__/graphics/terrain/concrete/concrete2.png",
            count = 4,
            size = 2,
            probability = 0.39,
          },
          {
            picture = "__NauvisDay__/graphics/terrain/concrete/concrete4.png",
            count = 4,
            size = 4,
            probability = 1,
          },
        },
        inner_corner =
        {
          picture = "__NauvisDay__/graphics/terrain/concrete/concrete-inner-corner.png",
          count = 32
        },
        outer_corner =
        {
          picture = "__NauvisDay__/graphics/terrain/concrete/concrete-outer-corner.png",
          count = 16
        },
        side =
        {
          picture = "__NauvisDay__/graphics/terrain/concrete/concrete-side.png",
          count = 16
        },
        u_transition =
        {
          picture = "__NauvisDay__/graphics/terrain/concrete/concrete-u.png",
          count = 16
        },
        o_transition =
        {
          picture = "__NauvisDay__/graphics/terrain/concrete/concrete-o.png",
          count = 1
        }
      },
      walking_sound =
      {
        {
          filename = "__base__/sound/walking/concrete-01.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-02.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-03.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-04.ogg",
          volume = 1.2
        }
      },
      map_color={r=30, g=30, b=30},
      ageing=0,
      vehicle_friction_modifier = 0.6
    },
  })