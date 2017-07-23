data:extend({
  {
    type = "constant-combinator",
    name = "pollution-detector",
    icon = "__base__/graphics/icons/constant-combinator.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "pollution-detector"},
    max_health = 50,
    corpse = "small-remnants",

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    item_slot_count = 1,

    sprites =
    {
      north = {
        filename = "__NauvisDay__/graphics/entity/pollution-detector.png",
        x = 0,
        y = 0,
        width = 61,
        height = 50,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      },
      east = {
        filename = "__NauvisDay__/graphics/entity/pollution-detector.png",
        x = 61,
        y = 0,
        width = 61,
        height = 50,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      },
      south = {
        filename = "__NauvisDay__/graphics/entity/pollution-detector.png",
        x = 122,
        y = 0,
        width = 61,
        height = 50,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      },
      west = {
        filename = "__NauvisDay__/graphics/entity/pollution-detector.png",
        x = 183,
        y = 0,
        width = 61,
        height = 50,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      }
    },

    activity_led_sprites = {
      north = {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-north.png",
        width = 11,
        height = 10,
        frame_count = 1,
        shift = {0.296875, -0.40625},
      },
      east = {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-east.png",
        width = 14,
        height = 12,
        frame_count = 1,
        shift = {0.25, -0.03125},
      },
      south = {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      },
      west = {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-west.png",
        width = 12,
        height = 12,
        frame_count = 1,
        shift = {-0.21875, -0.46875},
      }
    },

    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },

    circuit_wire_connection_points = {
      {
        shadow = {
          red = {0.15625, -0.28125},
          green = {0.65625, -0.25}
        },
        wire = {
          red = {-0.28125, -0.5625},
          green = {0.21875, -0.5625},
        }
      },
      {
        shadow = {
          red = {0.75, -0.15625},
          green = {0.75, 0.25},
        },
        wire = {
          red = {0.46875, -0.5},
          green = {0.46875, -0.09375},
        }
      },
      {
        shadow = {
          red = {0.75, 0.5625},
          green = {0.21875, 0.5625}
        },
        wire = {
          red = {0.28125, 0.15625},
          green = {-0.21875, 0.15625}
        }
      },
      {
        shadow = {
          red = {-0.03125, 0.28125},
          green = {-0.03125, -0.125},
        },
        wire = {
          red = {-0.46875, 0},
          green = {-0.46875, -0.40625},
        }
      }
    },

    circuit_wire_max_distance = 7.5
  }
})


data:extend({
  {
    type = "item",
    name = "pollution-detector",
    icon = "__NauvisDay__/graphics/icons/pollution-detector.png",
    flags = { "goes-to-quickbar" },
    subgroup = "circuit-network",
    place_result="pollution-detector",
    order = "b[combinators]-c[pollution-detector]",
    stack_size= 50,
  },
  { --for display in the circuit gui
    type = "capsule",
    name = "pollution",
    icon = "__NauvisDay__/graphics/icons/pollution.png",
    flags = { "goes-to-main-inventory" },
    subgroup = "raw-resource",
    order = "g[plastic-bar]-h[pollution]",
    capsule_action = {
      type = "use-on-self",
      attack_parameters = {
        type = "projectile",
        ammo_category = "capsule",
        cooldown = 30,
        range = 0,
        ammo_type = {
          category = "capsule",
          target_type = "position",
          action = {
            type = "direct",
            action_delivery = {
              type = "instant",
              target_effects = {
                type = "damage",
                damage = {type = "physical", amount = 20}
              }
            }
          }
        }
      }
    },
    stack_size= 1000,
  }
})



data:extend({
  {
    type = "recipe",
    name = "pollution-detector",
    icon = "__NauvisDay__/graphics/icons/pollution-detector.png",
    energy_required = 1.0,
    enabled = "false",
    ingredients =
    {
      {"constant-combinator", 1},
      {"electronic-circuit", 5},
      {"coal", 2},
    },
    result = "pollution-detector"
  }
})
