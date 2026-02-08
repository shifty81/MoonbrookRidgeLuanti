-- MoonBrook Ridge Core Mod
-- Basic nodes and world content

-- Register basic nodes for world generation
core.register_node("mbr_core:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	groups = {cracky = 3, stone = 1},
})

core.register_node("mbr_core:dirt", {
	description = "Dirt",
	tiles = {"default_dirt.png"},
	groups = {crumbly = 3, soil = 1},
})

core.register_node("mbr_core:dirt_with_grass", {
	description = "Dirt with Grass",
	tiles = {
		"default_grass.png",
		"default_dirt.png",
		{name = "default_dirt.png^default_grass_side.png", tileable_vertical = false}
	},
	groups = {crumbly = 3, soil = 1},
})

core.register_node("mbr_core:sand", {
	description = "Sand",
	tiles = {"default_sand.png"},
	groups = {crumbly = 3, sand = 1},
})

core.register_node("mbr_core:gravel", {
	description = "Gravel",
	tiles = {"default_gravel.png"},
	groups = {crumbly = 2},
})

core.register_node("mbr_core:tree", {
	description = "Tree Trunk",
	tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 1, tree = 1},
	on_place = core.rotate_node,
})

core.register_node("mbr_core:leaves", {
	description = "Leaves",
	drawtype = "allfaces_optional",
	tiles = {"default_leaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy = 3, leaves = 1},
})

core.register_node("mbr_core:wood", {
	description = "Wooden Planks",
	tiles = {"default_wood.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
})

core.register_node("mbr_core:water_source", {
	description = "Water Source",
	drawtype = "liquid",
	tiles = {
		{
			name = "default_water_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "default_water_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "mbr_core:water_flowing",
	liquid_alternative_source = "mbr_core:water_source",
	liquid_viscosity = 1,
	liquid_renewable = false,
	liquid_range = 8,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3},
})

core.register_node("mbr_core:water_flowing", {
	description = "Flowing Water",
	drawtype = "flowingliquid",
	tiles = {"default_water.png"},
	special_tiles = {
		{
			name = "default_water_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
		{
			name = "default_water_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mbr_core:water_flowing",
	liquid_alternative_source = "mbr_core:water_source",
	liquid_viscosity = 1,
	liquid_renewable = false,
	liquid_range = 8,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 1},
})

-- Register basic craft recipes
core.register_craft({
	output = "mbr_core:wood 4",
	recipe = {
		{"mbr_core:tree"},
	},
})

-- Mapgen aliases for world generation
core.register_alias("mapgen_stone", "mbr_core:stone")
core.register_alias("mapgen_water_source", "mbr_core:water_source")
core.register_alias("mapgen_river_water_source", "mbr_core:water_source")
core.register_alias("mapgen_dirt", "mbr_core:dirt")
core.register_alias("mapgen_dirt_with_grass", "mbr_core:dirt_with_grass")
core.register_alias("mapgen_sand", "mbr_core:sand")
core.register_alias("mapgen_gravel", "mbr_core:gravel")

minetest.log("action", "[MBR Core] Loaded with basic nodes")
