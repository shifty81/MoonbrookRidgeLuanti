-- mbr_core: Core systems and base nodes for MoonBrook Ridge

-- Global namespace
mbr = {}
mbr.players = {}
mbr.registered_callbacks = {}

-- =============================================================================
-- Helper Functions
-- =============================================================================

function mbr.clamp(val, min_val, max_val)
	if val < min_val then return min_val end
	if val > max_val then return max_val end
	return val
end

function mbr.get_player_data(player_name)
	if not mbr.players[player_name] then
		mbr.players[player_name] = {
			health = 20,
			energy = 100,
			money = 500,
			karma = 0,
			alignment = "neutral",
		}
	end
	return mbr.players[player_name]
end

function mbr.notify_player(player, message)
	local player_name = player:get_player_name()
	local hud_id = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 0.8},
		offset = {x = 0, y = 0},
		text = message,
		alignment = {x = 0, y = 0},
		scale = {x = 100, y = 100},
		number = 0xFFFFFF,
		z_index = 100,
	})
	core.after(3, function()
		local p = core.get_player_by_name(player_name)
		if p then
			p:hud_remove(hud_id)
		end
	end)
end

-- =============================================================================
-- Terrain Nodes
-- =============================================================================

core.register_node("mbr_core:stone", {
	description = "Stone",
	tiles = {"mbr_core_stone.png"},
	groups = {cracky = 3},
	drop = "mbr_core:stone",
	sounds = {},
})

core.register_node("mbr_core:dirt", {
	description = "Dirt",
	tiles = {"mbr_core_dirt.png"},
	groups = {crumbly = 3, soil = 1},
	sounds = {},
})

core.register_node("mbr_core:grass", {
	description = "Grass",
	tiles = {"mbr_core_grass_top.png", "mbr_core_dirt.png",
		{name = "mbr_core_dirt.png^mbr_core_grass_side.png", tileable_vertical = false}},
	groups = {crumbly = 3, soil = 1},
	drop = "mbr_core:dirt",
	sounds = {},
})

core.register_node("mbr_core:sand", {
	description = "Sand",
	tiles = {"mbr_core_sand.png"},
	groups = {crumbly = 3, falling_node = 1, sand = 1},
	sounds = {},
})

core.register_node("mbr_core:desert_sand", {
	description = "Desert Sand",
	tiles = {"mbr_core_desert_sand.png"},
	groups = {crumbly = 3, falling_node = 1, sand = 1},
	sounds = {},
})

core.register_node("mbr_core:snow", {
	description = "Snow",
	tiles = {"mbr_core_snow.png"},
	groups = {crumbly = 3, snowy = 1},
	sounds = {},
})

core.register_node("mbr_core:ice", {
	description = "Ice",
	tiles = {"mbr_core_ice.png"},
	groups = {cracky = 3, slippery = 3},
	sounds = {},
})

core.register_node("mbr_core:gravel", {
	description = "Gravel",
	tiles = {"mbr_core_gravel.png"},
	groups = {crumbly = 2, falling_node = 1},
	sounds = {},
})

core.register_node("mbr_core:clay", {
	description = "Clay",
	tiles = {"mbr_core_clay.png"},
	groups = {crumbly = 3},
	sounds = {},
})

core.register_node("mbr_core:mud", {
	description = "Mud",
	tiles = {"mbr_core_mud.png"},
	groups = {crumbly = 3},
	sounds = {},
})

core.register_node("mbr_core:crystal_stone", {
	description = "Crystal Stone",
	tiles = {"mbr_core_crystal_stone.png"},
	groups = {cracky = 2},
	light_source = 5,
	sounds = {},
})

core.register_node("mbr_core:ruins_stone", {
	description = "Ruins Stone",
	tiles = {"mbr_core_ruins_stone.png"},
	groups = {cracky = 3},
	sounds = {},
})

-- =============================================================================
-- Tree and Plant Nodes
-- =============================================================================

core.register_node("mbr_core:tree", {
	description = "Tree",
	tiles = {"mbr_core_tree_top.png", "mbr_core_tree_top.png", "mbr_core_tree.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, tree = 1},
	sounds = {},
})

core.register_node("mbr_core:leaves", {
	description = "Leaves",
	drawtype = "allfaces_optional",
	tiles = {"mbr_core_leaves.png"},
	paramtype = "light",
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
	sounds = {},
})

core.register_node("mbr_core:jungle_tree", {
	description = "Jungle Tree",
	tiles = {"mbr_core_jungle_tree_top.png", "mbr_core_jungle_tree_top.png", "mbr_core_jungle_tree.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, tree = 1},
	sounds = {},
})

core.register_node("mbr_core:jungle_leaves", {
	description = "Jungle Leaves",
	drawtype = "allfaces_optional",
	tiles = {"mbr_core_jungle_leaves.png"},
	paramtype = "light",
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
	sounds = {},
})

core.register_node("mbr_core:pine_tree", {
	description = "Pine Tree",
	tiles = {"mbr_core_pine_tree_top.png", "mbr_core_pine_tree_top.png", "mbr_core_pine_tree.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, tree = 1},
	sounds = {},
})

core.register_node("mbr_core:pine_leaves", {
	description = "Pine Needles",
	drawtype = "allfaces_optional",
	tiles = {"mbr_core_pine_leaves.png"},
	paramtype = "light",
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
	sounds = {},
})

core.register_node("mbr_core:cactus", {
	description = "Cactus",
	tiles = {"mbr_core_cactus_top.png", "mbr_core_cactus_top.png", "mbr_core_cactus.png"},
	groups = {choppy = 3},
	damage_per_second = 1,
	sounds = {},
})

core.register_node("mbr_core:papyrus", {
	description = "Papyrus",
	drawtype = "plantlike",
	tiles = {"mbr_core_papyrus.png"},
	inventory_image = "mbr_core_papyrus.png",
	wield_image = "mbr_core_papyrus.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
	},
	groups = {snappy = 3, flammable = 2},
	sounds = {},
})

core.register_node("mbr_core:dry_shrub", {
	description = "Dry Shrub",
	drawtype = "plantlike",
	tiles = {"mbr_core_dry_shrub.png"},
	inventory_image = "mbr_core_dry_shrub.png",
	wield_image = "mbr_core_dry_shrub.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flammable = 3, flora = 1, attached_node = 1},
	sounds = {},
})

-- Grass plants (5 variants)
for i = 1, 5 do
	core.register_node("mbr_core:grass_plant_" .. i, {
		description = "Grass",
		drawtype = "plantlike",
		tiles = {"mbr_core_grass_plant_" .. i .. ".png"},
		inventory_image = "mbr_core_grass_plant_" .. i .. ".png",
		wield_image = "mbr_core_grass_plant_" .. i .. ".png",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -0.5 + i * 0.2, 6 / 16},
		},
		groups = {snappy = 3, flammable = 3, flora = 1, attached_node = 1,
			not_in_creative_inventory = (i ~= 1 and 1 or 0)},
		drop = "mbr_core:grass_plant_1",
		sounds = {},
	})
end

-- Flowers
local flowers = {
	{"rose",      "Rose",      "mbr_core_flower_rose.png"},
	{"tulip",     "Tulip",     "mbr_core_flower_tulip.png"},
	{"dandelion", "Dandelion", "mbr_core_flower_dandelion.png"},
	{"viola",     "Viola",     "mbr_core_flower_viola.png"},
	{"lily",      "Lily",      "mbr_core_flower_lily.png"},
}

for _, flower in ipairs(flowers) do
	core.register_node("mbr_core:" .. flower[1], {
		description = flower[2],
		drawtype = "plantlike",
		tiles = {flower[3]},
		inventory_image = flower[3],
		wield_image = flower[3],
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		selection_box = {
			type = "fixed",
			fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 0.25, 4 / 16},
		},
		groups = {snappy = 3, flammable = 2, flora = 1, flower = 1, attached_node = 1},
		sounds = {},
	})
end

-- =============================================================================
-- Ore Nodes
-- =============================================================================

core.register_node("mbr_core:iron_ore", {
	description = "Iron Ore",
	tiles = {"mbr_core_stone.png^mbr_core_iron_ore.png"},
	groups = {cracky = 2},
	drop = "mbr_core:iron_ore",
	sounds = {},
})

core.register_node("mbr_core:gold_ore", {
	description = "Gold Ore",
	tiles = {"mbr_core_stone.png^mbr_core_gold_ore.png"},
	groups = {cracky = 2},
	drop = "mbr_core:gold_ore",
	sounds = {},
})

core.register_node("mbr_core:copper_ore", {
	description = "Copper Ore",
	tiles = {"mbr_core_stone.png^mbr_core_copper_ore.png"},
	groups = {cracky = 2},
	drop = "mbr_core:copper_ore",
	sounds = {},
})

core.register_node("mbr_core:diamond_ore", {
	description = "Diamond Ore",
	tiles = {"mbr_core_stone.png^mbr_core_diamond_ore.png"},
	groups = {cracky = 1},
	drop = "mbr_core:diamond_ore",
	sounds = {},
})

core.register_node("mbr_core:crystal_ore", {
	description = "Crystal Ore",
	tiles = {"mbr_core_stone.png^mbr_core_crystal_ore.png"},
	groups = {cracky = 1},
	light_source = 3,
	drop = "mbr_core:crystal_ore",
	sounds = {},
})

-- =============================================================================
-- Liquids
-- =============================================================================

core.register_node("mbr_core:water_source", {
	description = "Water Source",
	drawtype = "liquid",
	tiles = {
		{name = "mbr_core_water_source_animated.png", backface_culling = false,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0}},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "mbr_core:water_flowing",
	liquid_alternative_source = "mbr_core:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, cools_lava = 1},
})

core.register_node("mbr_core:water_flowing", {
	description = "Flowing Water",
	drawtype = "flowingliquid",
	tiles = {"mbr_core_water_source_animated.png"},
	special_tiles = {
		{name = "mbr_core_water_flowing_animated.png", backface_culling = false,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.5}},
		{name = "mbr_core_water_flowing_animated.png", backface_culling = true,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.5}},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mbr_core:water_flowing",
	liquid_alternative_source = "mbr_core:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 1, cools_lava = 1},
})

core.register_node("mbr_core:lava_source", {
	description = "Lava Source",
	drawtype = "liquid",
	tiles = {
		{name = "mbr_core_lava_source_animated.png", backface_culling = false,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.0}},
	},
	paramtype = "light",
	light_source = core.LIGHT_MAX - 1,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	damage_per_second = 4,
	liquidtype = "source",
	liquid_alternative_flowing = "mbr_core:lava_flowing",
	liquid_alternative_source = "mbr_core:lava_source",
	liquid_viscosity = 7,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1},
})

core.register_node("mbr_core:lava_flowing", {
	description = "Flowing Lava",
	drawtype = "flowingliquid",
	tiles = {"mbr_core_lava_source_animated.png"},
	special_tiles = {
		{name = "mbr_core_lava_flowing_animated.png", backface_culling = false,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.5}},
		{name = "mbr_core_lava_flowing_animated.png", backface_culling = true,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.5}},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source = core.LIGHT_MAX - 1,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	damage_per_second = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mbr_core:lava_flowing",
	liquid_alternative_source = "mbr_core:lava_source",
	liquid_viscosity = 7,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1, not_in_creative_inventory = 1},
})

-- =============================================================================
-- Player Callbacks
-- =============================================================================

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	mbr.get_player_data(name)
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	-- Data is stored in memory; clear on leave to free resources
	-- In a full implementation this would persist to mod storage
	mbr.players[name] = nil
end)

core.log("action", "[mbr_core] Loaded.")
