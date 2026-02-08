-- MoonBrook Ridge Tools
-- Basic tools for survival gameplay

-- Hand (for punching)
core.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x = 1, y = 1, z = 2.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times = {[2] = 3.00, [3] = 0.70}, uses = 0, maxlevel = 1},
			snappy = {times = {[3] = 0.40}, uses = 0, maxlevel = 1},
			oddly_breakable_by_hand = {times = {[1] = 3.50, [2] = 2.00, [3] = 0.70}, uses = 0, maxlevel = 3},
		},
		damage_groups = {fleshy = 1},
	}
})

-- Wooden Pickaxe
core.register_tool("mbr_tools:pick_wood", {
	description = "Wooden Pickaxe",
	inventory_image = "default_tool_woodpick.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level = 0,
		groupcaps = {
			cracky = {times = {[3] = 1.60}, uses = 10, maxlevel = 1},
		},
		damage_groups = {fleshy = 2},
	},
})

-- Stone Pickaxe
core.register_tool("mbr_tools:pick_stone", {
	description = "Stone Pickaxe",
	inventory_image = "default_tool_stonepick.png",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level = 0,
		groupcaps = {
			cracky = {times = {[2] = 2.0, [3] = 1.00}, uses = 20, maxlevel = 1},
		},
		damage_groups = {fleshy = 3},
	},
})

-- Wooden Axe
core.register_tool("mbr_tools:axe_wood", {
	description = "Wooden Axe",
	inventory_image = "default_tool_woodaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {
			choppy = {times = {[2] = 3.00, [3] = 1.60}, uses = 10, maxlevel = 1},
		},
		damage_groups = {fleshy = 2},
	},
})

-- Stone Axe
core.register_tool("mbr_tools:axe_stone", {
	description = "Stone Axe",
	inventory_image = "default_tool_stoneaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level = 0,
		groupcaps = {
			choppy = {times = {[1] = 3.00, [2] = 2.00, [3] = 1.30}, uses = 20, maxlevel = 1},
		},
		damage_groups = {fleshy = 3},
	},
})

-- Wooden Shovel
core.register_tool("mbr_tools:shovel_wood", {
	description = "Wooden Shovel",
	inventory_image = "default_tool_woodshovel.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times = {[1] = 3.00, [2] = 1.60, [3] = 0.60}, uses = 10, maxlevel = 1},
		},
		damage_groups = {fleshy = 2},
	},
})

-- Stone Shovel
core.register_tool("mbr_tools:shovel_stone", {
	description = "Stone Shovel",
	inventory_image = "default_tool_stoneshovel.png",
	tool_capabilities = {
		full_punch_interval = 1.4,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times = {[1] = 1.80, [2] = 1.20, [3] = 0.50}, uses = 20, maxlevel = 1},
		},
		damage_groups = {fleshy = 2},
	},
})

-- Crafting recipes
core.register_craft({
	output = "mbr_tools:pick_wood",
	recipe = {
		{"mbr_core:wood", "mbr_core:wood", "mbr_core:wood"},
		{"", "mbr_core:wood", ""},
		{"", "mbr_core:wood", ""},
	}
})

core.register_craft({
	output = "mbr_tools:pick_stone",
	recipe = {
		{"mbr_core:stone", "mbr_core:stone", "mbr_core:stone"},
		{"", "mbr_core:wood", ""},
		{"", "mbr_core:wood", ""},
	}
})

core.register_craft({
	output = "mbr_tools:axe_wood",
	recipe = {
		{"mbr_core:wood", "mbr_core:wood"},
		{"mbr_core:wood", "mbr_core:wood"},
		{"", "mbr_core:wood"},
	}
})

core.register_craft({
	output = "mbr_tools:axe_stone",
	recipe = {
		{"mbr_core:stone", "mbr_core:stone"},
		{"mbr_core:stone", "mbr_core:wood"},
		{"", "mbr_core:wood"},
	}
})

core.register_craft({
	output = "mbr_tools:shovel_wood",
	recipe = {
		{"mbr_core:wood"},
		{"mbr_core:wood"},
		{"mbr_core:wood"},
	}
})

core.register_craft({
	output = "mbr_tools:shovel_stone",
	recipe = {
		{"mbr_core:stone"},
		{"mbr_core:wood"},
		{"mbr_core:wood"},
	}
})

-- Give new players a basic tool
core.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	inv:add_item("main", "mbr_tools:pick_wood")
	inv:add_item("main", "mbr_tools:axe_wood")
	inv:add_item("main", "mbr_tools:shovel_wood")
end)

minetest.log("action", "[MBR Tools] Loaded")
