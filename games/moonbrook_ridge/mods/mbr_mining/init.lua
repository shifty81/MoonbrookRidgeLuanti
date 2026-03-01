-- MoonBrook Ridge Mining & Cave Exploration
-- Ore nodes, gem nodes, mining tools, and cave content

---------------------------------------------------------------------------
-- Ore Nodes
---------------------------------------------------------------------------

local ore_defs = {
	{name = "copper", desc = "Copper Ore", color = "#b87333",
		cracky = 3, y_min = -128, y_max = -16,
		scarcity = 512, clust_num = 5, clust_size = 3},
	{name = "iron", desc = "Iron Ore", color = "#808080",
		cracky = 3, y_min = -256, y_max = -32,
		scarcity = 729, clust_num = 4, clust_size = 3},
	{name = "silver", desc = "Silver Ore", color = "#c0c0c0",
		cracky = 2, y_min = -512, y_max = -64,
		scarcity = 1000, clust_num = 4, clust_size = 3},
	{name = "gold", desc = "Gold Ore", color = "#ffd700",
		cracky = 2, y_min = -1024, y_max = -128,
		scarcity = 1728, clust_num = 3, clust_size = 2},
	{name = "crystal", desc = "Crystal Ore", color = "#88ccff",
		cracky = 2, y_min = -2048, y_max = -256,
		scarcity = 2744, clust_num = 2, clust_size = 2},
}

for _, def in ipairs(ore_defs) do
	-- Register ore node
	core.register_node("mbr_mining:" .. def.name .. "_ore", {
		description = def.desc,
		tiles = {"[fill:16x16:#555555^[fill:4x4:#" .. def.color:sub(2) .. ""},
		groups = {cracky = def.cracky},
		drop = "mbr_mining:" .. def.name .. "_raw",
	})

	-- Register raw material
	core.register_craftitem("mbr_mining:" .. def.name .. "_raw", {
		description = "Raw " .. def.name:sub(1, 1):upper() .. def.name:sub(2),
		inventory_image = "[fill:16x16:" .. def.color,
	})

	-- Register ingot
	core.register_craftitem("mbr_mining:" .. def.name .. "_ingot", {
		description = def.name:sub(1, 1):upper() .. def.name:sub(2) .. " Ingot",
		inventory_image = "[fill:16x16:" .. def.color .. "^[brighten",
	})

	-- Craft: raw → ingot (1:1 until furnace is available)
	core.register_craft({
		output = "mbr_mining:" .. def.name .. "_ingot",
		recipe = {
			{"mbr_mining:" .. def.name .. "_raw"},
		},
	})

	-- Register ore generation
	core.register_ore({
		ore_type = "scatter",
		ore = "mbr_mining:" .. def.name .. "_ore",
		wherein = "mbr_core:stone",
		clust_scarcity = def.scarcity,
		clust_num_ores = def.clust_num,
		clust_size = def.clust_size,
		y_min = def.y_min,
		y_max = def.y_max,
	})
end

---------------------------------------------------------------------------
-- Gem Nodes
---------------------------------------------------------------------------

local gem_defs = {
	{name = "ruby", desc = "Ruby Ore", color = "#cc0033",
		gem_desc = "Ruby", y_min = -512, y_max = -64,
		scarcity = 1331},
	{name = "sapphire", desc = "Sapphire Ore", color = "#0033cc",
		gem_desc = "Sapphire", y_min = -512, y_max = -64,
		scarcity = 1331},
	{name = "emerald", desc = "Emerald Ore", color = "#00cc33",
		gem_desc = "Emerald", y_min = -1024, y_max = -128,
		scarcity = 2197},
	{name = "diamond", desc = "Diamond Ore", color = "#ccddff",
		gem_desc = "Diamond", y_min = -2048, y_max = -256,
		scarcity = 3375},
}

for _, def in ipairs(gem_defs) do
	-- Register gem ore node
	core.register_node("mbr_mining:" .. def.name .. "_ore", {
		description = def.desc,
		tiles = {"[fill:16x16:#555555^[fill:4x4:#" .. def.color:sub(2) .. ""},
		groups = {cracky = 2},
		drop = "mbr_mining:" .. def.name,
	})

	-- Register gem item
	core.register_craftitem("mbr_mining:" .. def.name, {
		description = def.gem_desc,
		inventory_image = "[fill:16x16:" .. def.color,
	})

	-- Register ore generation
	core.register_ore({
		ore_type = "scatter",
		ore = "mbr_mining:" .. def.name .. "_ore",
		wherein = "mbr_core:stone",
		clust_scarcity = def.scarcity,
		clust_num_ores = 2,
		clust_size = 2,
		y_min = def.y_min,
		y_max = def.y_max,
	})
end

---------------------------------------------------------------------------
-- Mining Tool Tiers
---------------------------------------------------------------------------

local pick_defs = {
	{name = "copper", desc = "Copper Pickaxe", color = "#b87333", dmg = 3,
		caps = {cracky = {times = {[1] = 4.0, [2] = 2.0, [3] = 1.0},
			uses = 20, maxlevel = 2}}},
	{name = "iron", desc = "Iron Pickaxe", color = "#808080", dmg = 4,
		caps = {cracky = {times = {[1] = 3.0, [2] = 1.5, [3] = 0.8},
			uses = 30, maxlevel = 3}}},
	{name = "silver", desc = "Silver Pickaxe", color = "#c0c0c0", dmg = 4,
		caps = {cracky = {times = {[1] = 2.5, [2] = 1.2, [3] = 0.6},
			uses = 25, maxlevel = 3}}},
	{name = "gold", desc = "Gold Pickaxe", color = "#ffd700", dmg = 3,
		caps = {cracky = {times = {[1] = 2.0, [2] = 1.0, [3] = 0.5},
			uses = 100, maxlevel = 3}}},
	{name = "crystal", desc = "Crystal Pickaxe", color = "#88ccff", dmg = 5,
		caps = {cracky = {times = {[1] = 1.5, [2] = 0.8, [3] = 0.4},
			uses = 40, maxlevel = 4}}},
}

for _, def in ipairs(pick_defs) do
	core.register_tool("mbr_mining:pick_" .. def.name, {
		description = def.desc,
		inventory_image = "[fill:16x16:" .. def.color,
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = 1,
			groupcaps = def.caps,
			damage_groups = {fleshy = def.dmg},
		},
	})

	-- Craft: 3 ingots on top, 2 wood planks as handle
	local ingot = "mbr_mining:" .. def.name .. "_ingot"
	core.register_craft({
		output = "mbr_mining:pick_" .. def.name,
		recipe = {
			{ingot, ingot, ingot},
			{"", "mbr_core:wood", ""},
			{"", "mbr_core:wood", ""},
		},
	})
end

---------------------------------------------------------------------------
-- Lava Nodes
---------------------------------------------------------------------------

core.register_node("mbr_mining:lava_source", {
	description = "Lava Source",
	drawtype = "liquid",
	tiles = {"[fill:16x16:#ff4400"},
	special_tiles = {
		{name = "[fill:16x16:#ff4400", backface_culling = false},
		{name = "[fill:16x16:#ff4400", backface_culling = true},
	},
	paramtype = "light",
	light_source = 13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	damage_per_second = 4,
	liquidtype = "source",
	liquid_alternative_flowing = "mbr_mining:lava_flowing",
	liquid_alternative_source = "mbr_mining:lava_source",
	liquid_viscosity = 7,
	liquid_renewable = false,
	liquid_range = 3,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1},
})

core.register_node("mbr_mining:lava_flowing", {
	description = "Flowing Lava",
	drawtype = "flowingliquid",
	tiles = {"[fill:16x16:#ff4400"},
	special_tiles = {
		{name = "[fill:16x16:#ff4400", backface_culling = false},
		{name = "[fill:16x16:#ff4400", backface_culling = true},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source = 13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	damage_per_second = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mbr_mining:lava_flowing",
	liquid_alternative_source = "mbr_mining:lava_source",
	liquid_viscosity = 7,
	liquid_renewable = false,
	liquid_range = 3,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1, not_in_creative_inventory = 1},
})

---------------------------------------------------------------------------
-- Toxic Gas (Cave Hazard)
---------------------------------------------------------------------------

core.register_node("mbr_mining:toxic_gas", {
	description = "Toxic Gas",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = true,
	drop = "",
	groups = {not_in_creative_inventory = 1},
})

core.register_abm({
	label = "Toxic gas damage",
	nodenames = {"mbr_mining:toxic_gas"},
	interval = 2,
	chance = 1,
	action = function(pos)
		local objs = core.get_objects_inside_radius(pos, 2)
		for _, obj in ipairs(objs) do
			if obj:is_player() then
				obj:set_hp(obj:get_hp() - 1, {type = "node", node = "mbr_mining:toxic_gas"})
			end
		end
	end,
})

---------------------------------------------------------------------------
-- Integration with crafting system
---------------------------------------------------------------------------

if mbr and mbr.crafting and mbr.crafting.register_material then
	local ingot_materials = {
		{id = "mbr_mining:copper_ingot",  desc = "Copper Ingot",  color = "#b87333", quality = 3},
		{id = "mbr_mining:iron_ingot",    desc = "Iron Ingot",    color = "#808080", quality = 4},
		{id = "mbr_mining:silver_ingot",  desc = "Silver Ingot",  color = "#c0c0c0", quality = 4},
		{id = "mbr_mining:gold_ingot",    desc = "Gold Ingot",    color = "#ffd700", quality = 4},
		{id = "mbr_mining:crystal_ingot", desc = "Crystal Ingot", color = "#88ccff", quality = 5},
	}
	for _, mat in ipairs(ingot_materials) do
		mbr.crafting.register_material(mat.id, {
			description = mat.desc,
			texture = "[fill:16x16:" .. mat.color .. "^[brighten",
			quality = mat.quality,
		})
	end
end

---------------------------------------------------------------------------
-- Chat Command: Mining Guide
---------------------------------------------------------------------------

core.register_chatcommand("mining_guide", {
	description = "Shows ore types, depths, and required pickaxe tiers",
	func = function(name)
		local lines = {
			"=== MoonBrook Ridge Mining Guide ===",
			"",
			"-- Ore Deposits --",
			"Copper Ore:  y -16 to -128   (any pickaxe)",
			"Iron Ore:    y -32 to -256   (copper pick or better)",
			"Silver Ore:  y -64 to -512   (iron pick or better)",
			"Gold Ore:    y -128 to -1024 (iron pick or better)",
			"Crystal Ore: y -256 to -2048 (silver pick or better)",
			"",
			"-- Gem Deposits --",
			"Ruby:     y -64 to -512   (iron pick or better)",
			"Sapphire: y -64 to -512   (iron pick or better)",
			"Emerald:  y -128 to -1024 (iron pick or better)",
			"Diamond:  y -256 to -2048 (silver pick or better)",
			"",
			"-- Pickaxe Tiers --",
			"Copper:  Good starter upgrade",
			"Iron:    Standard tier, mines most ores",
			"Silver:  Faster mining speed",
			"Gold:    Very fast but fragile",
			"Crystal: Best tier, mines everything",
			"",
			"-- Hazards --",
			"Lava: Found deep underground, deals damage on contact",
			"Toxic Gas: Invisible, damages nearby players in deep caves",
		}
		return true, table.concat(lines, "\n")
	end,
})

core.log("action", "[MBR Mining] Loaded with ores, gems, tools, and cave content")
