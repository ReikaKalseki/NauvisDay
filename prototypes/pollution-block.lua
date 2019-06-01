data:extend(
{
   {
    type = "item",
    name = "pollution-block",
    icon = "__NauvisDay__/graphics/icons/pollution-block.png",
    flags = {},
    subgroup = "intermediate-product",
    --order = "f[stone-wall]-f[tough-wall-1-2]",
    place_result = "pollution-block",	
    stack_size = 20,
	icon_size = 32
  }
}
)

data:extend(
{
	{
		type = "simple-entity",
		name = "pollution-block",
		flags = {"placeable-player"},
		icon = "__NauvisDay__/graphics/icons/pollution-block.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		minable = {mining_time = 2, result = "pollution-block"},
		max_health = 25,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
		pictures =
		{
			{
			filename = "__NauvisDay__/graphics/entity/pollution-block.png",
			width = 32,
			height = 32,
		}
      }
	}
}
)