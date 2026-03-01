-- MoonBrook Ridge Foraging & Gathering Mod
-- Wild herbs, mushrooms, berries, and forageable items

local modname = "mbr_foraging"

-- Helper: get current season name safely
local function get_current_season()
	if mbr and mbr.time then
		return mbr.time.get_season_name()
	end
	return "Spring"
end

-- Helper: selection box for plantlike forageables
local plant_selection_box = {
	type = "fixed",
	fixed = {-0.3, -0.5, -0.3, 0.3, 0.2, 0.3},
}

--------------------------------------------------------------------------------
-- WILD HERBS
--------------------------------------------------------------------------------

core.register_node("mbr_foraging:herb_mint", {
	description = "Wild Mint",
	drawtype = "plantlike",
	tiles = {"[fill:16x16:#3CB371"},
	inventory_image = "[fill:16x16:#3CB371",
	wield_image = "[fill:16x16:#3CB371",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = plant_selection_box,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	drop = "mbr_foraging:herb_mint",
	on_dig = function(pos, node, digger)
		if digger and math.random(100) <= 5 then
			local inv = digger:get_inventory()
			if inv then
				inv:add_item("main", "mbr_foraging:four_leaf_clover")
			end
		end
		return minetest.node_dig(pos, node, digger)
	end,
})

core.register_node("mbr_foraging:herb_basil", {
	description = "Wild Basil",
	drawtype = "plantlike",
	tiles = {"[fill:16x16:#2E8B57"},
	inventory_image = "[fill:16x16:#2E8B57",
	wield_image = "[fill:16x16:#2E8B57",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = plant_selection_box,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	drop = "mbr_foraging:herb_basil",
	on_dig = function(pos, node, digger)
		if digger and math.random(100) <= 5 then
			local inv = digger:get_inventory()
			if inv then
				inv:add_item("main", "mbr_foraging:ancient_root")
			end
		end
		return minetest.node_dig(pos, node, digger)
	end,
})

core.register_node("mbr_foraging:herb_lavender", {
	description = "Wild Lavender",
	drawtype = "plantlike",
	tiles = {"[fill:16x16:#9370DB"},
	inventory_image = "[fill:16x16:#9370DB",
	wield_image = "[fill:16x16:#9370DB",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = plant_selection_box,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	drop = "mbr_foraging:herb_lavender",
	on_dig = function(pos, node, digger)
		if digger and math.random(100) <= 5 then
			local inv = digger:get_inventory()
			if inv then
				inv:add_item("main", "mbr_foraging:fairy_dust")
			end
		end
		return minetest.node_dig(pos, node, digger)
	end,
})

core.register_node("mbr_foraging:herb_ginseng", {
	description = "Wild Ginseng (Rare)",
	drawtype = "plantlike",
	tiles = {"[fill:16x16:#8FBC8F"},
	inventory_image = "[fill:16x16:#8FBC8F",
	wield_image = "[fill:16x16:#8FBC8F",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = plant_selection_box,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	drop = "mbr_foraging:herb_ginseng",
	on_dig = function(pos, node, digger)
		if digger and math.random(100) <= 5 then
			local inv = digger:get_inventory()
			if inv then
				inv:add_item("main", "mbr_foraging:fairy_dust")
			end
		end
		return minetest.node_dig(pos, node, digger)
	end,
})

--------------------------------------------------------------------------------
-- MUSHROOMS
--------------------------------------------------------------------------------

core.register_node("mbr_foraging:mushroom_button", {
	description = "Button Mushroom",
	drawtype = "plantlike",
	tiles = {"[fill:16x16:#F5F5DC"},
	inventory_image = "[fill:16x16:#F5F5DC",
	wield_image = "[fill:16x16:#F5F5DC",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = plant_selection_box,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	drop = "mbr_foraging:mushroom_button",
	on_dig = function(pos, node, digger)
		if digger and math.random(100) <= 5 then
			local inv = digger:get_inventory()
			if inv then
				inv:add_item("main", "mbr_foraging:ancient_root")
			end
		end
		return minetest.node_dig(pos, node, digger)
	end,
})

core.register_node("mbr_foraging:mushroom_chanterelle", {
	description = "Chanterelle Mushroom",
	drawtype = "plantlike",
	tiles = {"[fill:16x16:#FFD700"},
	inventory_image = "[fill:16x16:#FFD700",
	wield_image = "[fill:16x16:#FFD700",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = plant_selection_box,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	drop = "mbr_foraging:mushroom_chanterelle",
	on_dig = function(pos, node, digger)
		if digger and math.random(100) <= 5 then
			local inv = digger:get_inventory()
			if inv then
				inv:add_item("main", "mbr_foraging:fairy_dust")
			end
		end
		return minetest.node_dig(pos, node, digger)
	end,
})

core.register_node("mbr_foraging:mushroom_morel", {
	description = "Morel Mushroom",
	drawtype = "plantlike",
	tiles = {"[fill:16x16:#8B7355"},
	inventory_image = "[fill:16x16:#8B7355",
	wield_image = "[fill:16x16:#8B7355",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = plant_selection_box,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	drop = "mbr_foraging:mushroom_morel",
	on_dig = function(pos, node, digger)
		if digger and math.random(100) <= 5 then
			local inv = digger:get_inventory()
			if inv then
				inv:add_item("main", "mbr_foraging:ancient_root")
			end
		end
		return minetest.node_dig(pos, node, digger)
	end,
})

core.register_node("mbr_foraging:mushroom_truffle", {
	description = "Truffle (Rare)",
	drawtype = "plantlike",
	tiles = {"[fill:16x16:#4A3728"},
	inventory_image = "[fill:16x16:#4A3728",
	wield_image = "[fill:16x16:#4A3728",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = plant_selection_box,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	drop = "mbr_foraging:mushroom_truffle",
	on_dig = function(pos, node, digger)
		if digger and math.random(100) <= 5 then
			local inv = digger:get_inventory()
			if inv then
				inv:add_item("main", "mbr_foraging:four_leaf_clover")
			end
		end
		return minetest.node_dig(pos, node, digger)
	end,
})

--------------------------------------------------------------------------------
-- BERRIES (bush nodes that leave bare bush when broken)
--------------------------------------------------------------------------------

-- Bare bush node (regrows via ABM)
core.register_node("mbr_foraging:bush_bare", {
	description = "Bare Berry Bush",
	drawtype = "plantlike",
	tiles = {"[fill:16x16:#556B2F"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = plant_selection_box,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	drop = "",
})

-- Helper to create berry bush nodes
local function register_berry_bush(name, def)
	core.register_node("mbr_foraging:" .. name, {
		description = def.description,
		drawtype = "plantlike",
		tiles = {def.tile},
		inventory_image = def.tile,
		wield_image = def.tile,
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		selection_box = plant_selection_box,
		groups = {snappy = 3, flora = 1, attached_node = 1},
		drop = "mbr_foraging:" .. name,
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			-- Place bare bush for regrowth
			minetest.set_node(pos, {name = "mbr_foraging:bush_bare"})
			-- Rare forageable drop chance
			if digger and math.random(100) <= 5 then
				local inv = digger:get_inventory()
				if inv then
					inv:add_item("main", "mbr_foraging:four_leaf_clover")
				end
			end
		end,
	})
end

register_berry_bush("berry_blueberry", {
	description = "Blueberry Bush",
	tile = "[fill:16x16:#4169E1",
})

register_berry_bush("berry_raspberry", {
	description = "Raspberry Bush",
	tile = "[fill:16x16:#DC143C",
})

register_berry_bush("berry_blackberry", {
	description = "Blackberry Bush",
	tile = "[fill:16x16:#4B0082",
})

register_berry_bush("berry_winterberry", {
	description = "Winterberry Bush",
	tile = "[fill:16x16:#CD5C5C",
})

--------------------------------------------------------------------------------
-- RARE FORAGEABLES (craftitems only)
--------------------------------------------------------------------------------

core.register_craftitem("mbr_foraging:four_leaf_clover", {
	description = "Four-Leaf Clover (Lucky!)",
	inventory_image = "[fill:16x16:#00FF7F",
})

core.register_craftitem("mbr_foraging:ancient_root", {
	description = "Ancient Root",
	inventory_image = "[fill:16x16:#8B4513",
})

core.register_craftitem("mbr_foraging:fairy_dust", {
	description = "Fairy Dust",
	inventory_image = "[fill:16x16:#FFD1DC",
})

--------------------------------------------------------------------------------
-- FOOD REGISTRATION
--------------------------------------------------------------------------------

if mbr and mbr.survival then
	mbr.survival.register_food("mbr_foraging:herb_mint_item", {
		description = "Wild Mint",
		texture = "[fill:16x16:#3CB371",
		hunger_restore = 3,
		thirst_restore = 5,
	})

	mbr.survival.register_food("mbr_foraging:herb_basil_item", {
		description = "Wild Basil",
		texture = "[fill:16x16:#2E8B57",
		hunger_restore = 4,
	})

	mbr.survival.register_food("mbr_foraging:herb_ginseng_item", {
		description = "Wild Ginseng",
		texture = "[fill:16x16:#8FBC8F",
		hunger_restore = 8,
		thirst_restore = 5,
	})

	mbr.survival.register_food("mbr_foraging:mushroom_button_item", {
		description = "Button Mushroom",
		texture = "[fill:16x16:#F5F5DC",
		hunger_restore = 5,
	})

	mbr.survival.register_food("mbr_foraging:mushroom_chanterelle_item", {
		description = "Chanterelle Mushroom",
		texture = "[fill:16x16:#FFD700",
		hunger_restore = 7,
	})

	mbr.survival.register_food("mbr_foraging:mushroom_morel_item", {
		description = "Morel Mushroom",
		texture = "[fill:16x16:#8B7355",
		hunger_restore = 8,
	})

	mbr.survival.register_food("mbr_foraging:mushroom_truffle_item", {
		description = "Truffle",
		texture = "[fill:16x16:#4A3728",
		hunger_restore = 12,
	})

	mbr.survival.register_food("mbr_foraging:berry_blueberry_item", {
		description = "Blueberry",
		texture = "[fill:16x16:#4169E1",
		hunger_restore = 4,
		thirst_restore = 3,
	})

	mbr.survival.register_food("mbr_foraging:berry_raspberry_item", {
		description = "Raspberry",
		texture = "[fill:16x16:#DC143C",
		hunger_restore = 3,
		thirst_restore = 4,
	})

	mbr.survival.register_food("mbr_foraging:berry_blackberry_item", {
		description = "Blackberry",
		texture = "[fill:16x16:#4B0082",
		hunger_restore = 5,
		thirst_restore = 2,
	})

	mbr.survival.register_food("mbr_foraging:berry_winterberry_item", {
		description = "Winterberry",
		texture = "[fill:16x16:#CD5C5C",
		hunger_restore = 6,
		thirst_restore = 3,
	})

	-- Crafted food items
	mbr.survival.register_food("mbr_foraging:herbal_tea", {
		description = "Herbal Tea",
		texture = "[fill:16x16:#90EE90",
		hunger_restore = 5,
		thirst_restore = 15,
	})

	mbr.survival.register_food("mbr_foraging:mushroom_stew", {
		description = "Mushroom Stew",
		texture = "[fill:16x16:#8B6914",
		hunger_restore = 15,
		thirst_restore = 5,
	})

	mbr.survival.register_food("mbr_foraging:berry_jam", {
		description = "Berry Jam",
		texture = "[fill:16x16:#C71585",
		hunger_restore = 10,
		thirst_restore = 5,
	})

	minetest.log("action", "[MBR Foraging] Registered food items with survival system")
else
	minetest.log("warning", "[MBR Foraging] MBR survival system not found, food effects unavailable")
end

--------------------------------------------------------------------------------
-- CRAFTING RECIPES
--------------------------------------------------------------------------------

-- Herbal Tea: lavender + mint + water_bottle
if minetest.registered_items["mbr_items:water_bottle"] then
	core.register_craft({
		output = "mbr_foraging:herbal_tea",
		recipe = {
			{"mbr_foraging:herb_lavender", "mbr_foraging:herb_mint", "mbr_items:water_bottle"},
		},
	})
end

-- Mushroom Stew: 2 mushrooms (any) + potato (if exists)
local stew_ingredient = "mbr_items:potato"
if not minetest.registered_items[stew_ingredient] then
	stew_ingredient = "mbr_foraging:mushroom_button"
end
core.register_craft({
	output = "mbr_foraging:mushroom_stew",
	recipe = {
		{"group:snappy", "group:snappy", stew_ingredient},
	},
})

-- Berry Jam: 3 berries (any)
core.register_craft({
	output = "mbr_foraging:berry_jam",
	recipe = {
		{"mbr_foraging:berry_blueberry", "mbr_foraging:berry_raspberry", "mbr_foraging:berry_blackberry"},
	},
})

--------------------------------------------------------------------------------
-- SEASONAL SPAWNING ABM
--------------------------------------------------------------------------------

-- Seasonal forageable tables
local seasonal_spawns = {
	Spring = {
		"mbr_foraging:herb_mint",
		"mbr_foraging:herb_lavender",
		"mbr_foraging:mushroom_button",
		"mbr_foraging:mushroom_morel",
	},
	Summer = {
		"mbr_foraging:herb_mint",
		"mbr_foraging:herb_basil",
		"mbr_foraging:berry_blueberry",
		"mbr_foraging:berry_raspberry",
	},
	Fall = {
		"mbr_foraging:herb_basil",
		"mbr_foraging:mushroom_chanterelle",
		"mbr_foraging:mushroom_truffle",
		"mbr_foraging:berry_raspberry",
		"mbr_foraging:berry_blackberry",
	},
	Winter = {
		"mbr_foraging:mushroom_truffle",
		"mbr_foraging:berry_winterberry",
	},
}

core.register_abm({
	label = "Forageable seasonal spawning",
	nodenames = {"mbr_core:dirt_with_grass"},
	interval = 120,
	chance = 50,
	action = function(pos, node)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local above_node = minetest.get_node(above)
		if above_node.name ~= "air" then
			return
		end

		-- Check light level (not in caves)
		local light = minetest.get_node_light(above, 0.5)
		if not light or light < 10 then
			return
		end

		local season = get_current_season()
		local spawns = seasonal_spawns[season]
		if not spawns or #spawns == 0 then
			return
		end

		-- Ginseng: any season but very low chance
		if math.random(200) == 1 then
			minetest.set_node(above, {name = "mbr_foraging:herb_ginseng"})
			return
		end

		local chosen = spawns[math.random(#spawns)]
		minetest.set_node(above, {name = chosen})
	end,
})

--------------------------------------------------------------------------------
-- BERRY BUSH REGROWTH ABM
--------------------------------------------------------------------------------

-- Season-appropriate berry types for regrowth
local seasonal_berries = {
	Spring = {},
	Summer = {
		"mbr_foraging:berry_blueberry",
		"mbr_foraging:berry_raspberry",
	},
	Fall = {
		"mbr_foraging:berry_raspberry",
		"mbr_foraging:berry_blackberry",
	},
	Winter = {
		"mbr_foraging:berry_winterberry",
	},
}

core.register_abm({
	label = "Berry bush regrowth",
	nodenames = {"mbr_foraging:bush_bare"},
	interval = 180,
	chance = 5,
	action = function(pos, node)
		local season = get_current_season()
		local berries = seasonal_berries[season]
		if not berries or #berries == 0 then
			return
		end

		local chosen = berries[math.random(#berries)]
		minetest.set_node(pos, {name = chosen})
	end,
})

--------------------------------------------------------------------------------
-- MAPGEN DECORATIONS
--------------------------------------------------------------------------------

-- Common herbs on grass
core.register_decoration({
	deco_type = "simple",
	place_on = {"mbr_core:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.002,
	y_max = 31000,
	y_min = 1,
	decoration = "mbr_foraging:herb_mint",
})

core.register_decoration({
	deco_type = "simple",
	place_on = {"mbr_core:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.002,
	y_max = 31000,
	y_min = 1,
	decoration = "mbr_foraging:herb_basil",
})

core.register_decoration({
	deco_type = "simple",
	place_on = {"mbr_core:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.001,
	y_max = 31000,
	y_min = 1,
	decoration = "mbr_foraging:herb_lavender",
})

-- Common berries on grass
core.register_decoration({
	deco_type = "simple",
	place_on = {"mbr_core:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.003,
	y_max = 31000,
	y_min = 1,
	decoration = "mbr_foraging:berry_blueberry",
})

core.register_decoration({
	deco_type = "simple",
	place_on = {"mbr_core:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.003,
	y_max = 31000,
	y_min = 1,
	decoration = "mbr_foraging:berry_raspberry",
})

-- Common mushrooms on dirt
core.register_decoration({
	deco_type = "simple",
	place_on = {"mbr_core:dirt_with_grass", "mbr_core:dirt"},
	sidelen = 16,
	fill_ratio = 0.002,
	y_max = 31000,
	y_min = 1,
	decoration = "mbr_foraging:mushroom_button",
})

-- Rare forageables at very low density
core.register_decoration({
	deco_type = "simple",
	place_on = {"mbr_core:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.001,
	y_max = 31000,
	y_min = 1,
	decoration = "mbr_foraging:herb_ginseng",
})

core.register_decoration({
	deco_type = "simple",
	place_on = {"mbr_core:dirt_with_grass", "mbr_core:dirt"},
	sidelen = 16,
	fill_ratio = 0.001,
	y_max = 31000,
	y_min = 1,
	decoration = "mbr_foraging:mushroom_chanterelle",
})

core.register_decoration({
	deco_type = "simple",
	place_on = {"mbr_core:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.005,
	y_max = 31000,
	y_min = 1,
	decoration = "mbr_foraging:berry_blackberry",
})

--------------------------------------------------------------------------------
-- CHAT COMMAND: /forage_guide
--------------------------------------------------------------------------------

core.register_chatcommand("forage_guide", {
	description = "Shows what forageables are available this season",
	func = function(name, param)
		local season = get_current_season()
		local lines = {"=== Foraging Guide - " .. season .. " ==="}

		local guide = {
			Spring = {
				"Herbs: Mint (green, +3 hunger +5 thirst), Lavender (purple, crafting)",
				"Mushrooms: Button (white, +5 hunger), Morel (brown, +8 hunger)",
				"Rare: Four-Leaf Clover (luck!), Ginseng (+8 hunger +5 thirst)",
			},
			Summer = {
				"Herbs: Mint (green, +3 hunger +5 thirst), Basil (dark green, +4 hunger)",
				"Berries: Blueberry (blue, +4 hunger +3 thirst), Raspberry (red, +3 hunger +4 thirst)",
				"Rare: Fairy Dust (magical crafting), Ginseng (+8 hunger +5 thirst)",
			},
			Fall = {
				"Herbs: Basil (dark green, +4 hunger)",
				"Mushrooms: Chanterelle (gold, +7 hunger), Truffle (dark brown, +12 hunger)",
				"Berries: Raspberry (red, +3 hunger +4 thirst), Blackberry (purple, +5 hunger +2 thirst)",
				"Rare: Ancient Root (potion crafting), Ginseng (+8 hunger +5 thirst)",
			},
			Winter = {
				"Mushrooms: Truffle (dark brown, +12 hunger)",
				"Berries: Winterberry (red, +6 hunger +3 thirst)",
				"Rare: Ancient Root (potion crafting), Ginseng (+8 hunger +5 thirst)",
			},
		}

		local entries = guide[season]
		if entries then
			for _, line in ipairs(entries) do
				table.insert(lines, "  " .. line)
			end
		else
			table.insert(lines, "  No foraging data available for this season.")
		end

		table.insert(lines, "")
		table.insert(lines, "Tip: Rare items (Clover, Ancient Root, Fairy Dust) drop ~5% when foraging!")
		table.insert(lines, "Recipes: Herbal Tea (lavender+mint+water), Mushroom Stew, Berry Jam")

		return true, table.concat(lines, "\n")
	end,
})

minetest.log("action", "[MBR Foraging] Loaded with herbs, mushrooms, berries, and seasonal foraging")
